# Sender SMS via rfsms.ru
# v0.1.1
# encoding: utf-8

require 'net/http'
require 'net/https'
require 'nori'
require 'i18n'
require 'active_support/all'

Nori.configure do |config|
  config.convert_tags_to { |tag| tag.to_s.underscore.to_sym }
end

module Rfsms
  DATEREGEXP = /^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[1-2]\d|3[01]) (?:[01]\d|2[0-4]):(?:[0-5]\d):(?:[0-5]\d)$/
  DATEFORMAT = "%Y-%m-%d %H:%M:%S"
  INTEGER_REGEXP = /^\d+$/
  FLOAT_REGEXP = /^\d+(?:\.\d+)?$/

  class AnswerError < RuntimeError; end
  class IncorrectAnswerError < AnswerError; end

  class Answer
    attr_reader :descr

    # Инициализация объекта ответа с проверкой элементов в передаваемом блоке validate.
    # Если validate возвращает false или nil возникает исключение Rfsms::IncorrectAnswerError
    def initialize(body, &validate)
      body_e = Nori.parse(body, :nokogiri)
      p body_e if $DEBUG

      elements = body_e[:data]
      raise IncorrectAnswerError unless elements.is_a?(Hash)
      p elements if $DEBUG
      
      if code = elements.delete(:code) and @descr = elements.delete(:descr)
        if code == '1'
          raise IncorrectAnswerError if validate and !validate.call(elements)
          elements.each_pair do |tag, value|
            instance_variable_set(:"@#{tag}", value)
          end
        else
          raise AnswerError, "#{code}: #{@descr}"
        end
      else
        raise IncorrectAnswerError
      end
    end
  end

  class CancelAnswer < Answer
    attr_reader :action, :cancel_col

    def initialize(body)
      super(body) do |e|
        e[:action] =~ /^(?:check|make)$/
      end
      @cancel_col = @cancel_col.to_i
    end
  end
  
  class SendAnswer < Answer
    attr_reader :smsid, :datetime, :action, :all_recivers,
      :col_send_abonent, :col_non_send_abonent, :price_of_sending,
      :colsms_of_sending, :price

    def initialize(body)
      super(body) do |e|
        e.has_key?(:smsid) and
        e[:datetime] =~ DATEREGEXP and
        e[:action] =~ /^(?:check|make|send)$/ and
        e[:all_recivers] =~ INTEGER_REGEXP and
        e[:col_send_abonent] =~ INTEGER_REGEXP and
        e[:col_non_send_abonent] =~ INTEGER_REGEXP and
        e[:price_of_sending] =~ FLOAT_REGEXP and
        e[:colsms_of_sending] =~ INTEGER_REGEXP and
        e[:price] =~ FLOAT_REGEXP
      end
      @datetime = DateTime.strptime(@datetime, DATEFORMAT)
      @all_recivers = @all_recivers.to_i
      @col_send_abonent = @col_send_abonent.to_i
      @col_non_send_abonent = @col_non_send_abonent.to_i
      @price_of_sending = @price_of_sending.to_f
      @colsms_of_sending = @colsms_of_sending.to_i
      @price = @price.to_f
    end
  end

  class BalanceAnswer < Answer
    attr_reader :account

    def to_f
      self.account
    end

    def to_s
      self.to_f.to_s
    end

    def to_str
      self.to_s
    end

    def +(other)
      case other
      when Float
        self.to_f + other
      when Integer, BalanceAnswer
        self.to_f + other.to_f
      else
        n1, n2 = other.coerce(self)
        n1 + n2
      end
    end

    def coerce(other)
      case other
      when Float
        return other, self.to_f
      when Integer
        return other.to_f, self
      when String
        return other, self.to_s
      end
    end

    def initialize(body)
      super(body) do |e|
        e[:account] =~ FLOAT_REGEXP
      end
      @account = @account.to_f
    end
  end

  class ReportAnswer < Answer
    attr_reader :sms
    class SMS
      attr_reader :smsid, :datetime, :text, :source, :all_col, :delivered_col,
        :not_delivered_col, :waiting_col, :enqueued_col, :payment

      def initialize(elements)
        p elements if $DEBUG
        unless @smsid = elements[:smsid] and
              @datetime = elements[:datetime] and @datetime =~ DATEREGEXP and
              @text = elements[:text] and
              @source = elements[:source] and
              @all_col = elements[:all_col] and
              @delivered_col = elements[:delivered_col] and
              @not_delivered_col = elements[:not_delivered_col] and
              @waiting_col = elements[:waiting_col] and
              @enqueued_col = elements[:enqueued_col] and
              @payment = elements[:payment]
          raise IncorrectAnswerError
        end
      end
    end

    def initialize(body)
      super(body)
      @sms = case @sms
      when Hash
        [SMS.new(@sms)]
      when Array
        @sms.map {|sms| SMS.new(sms) }
      else
        []
      end
    end
  end

  class Connection
    def initialize(url, login, password)
      @uri = URI.parse(url)
      @connection = Net::HTTP.new(@uri.host, @uri.port)
      @connection.use_ssl = true
      @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @login = login
      @password = password
    end

    # send(text, phones, datetime = nil, source = nil, onlydelivery = false)
    # отправляет text по указанным phones = [].
    # phones может быть хэшем где значения - индивидуальный текст
    def send(text, phones, datetime = nil, source = nil, onlydelivery = false)
      message = message_header
      message << "<text>#{text}</text>"

      case phones
      when Array
        phones.each do |phone|
          message << "  <to number='#{phone}'></to>\n"
        end
      when Hash
        phones.each_pair do |phone, t|
          message << "  <to number='#{phone}'>#{t}</to>\n"
        end
      end

      message << "<datetime>#{datetime.strftime(DATEFORMAT)}</datetime>" if datetime
      message << "<source>#{source}</source>" if source
      message << "<onlydelivery>1</onlydelivery>" if onlydelivery
      message << message_footer

      STDERR.puts "+SENDED:\n"+message+"\n-SENDED\n" if $DEBUG
      @connection.request_post('/send.xml', message) do |response|
        case response
        when Net::HTTPSuccess
          return SendAnswer.new(response.body)
        else
          response.error!
        end
      end
    end

    # получает отчет о списке рассылки при указанных датах начала(start) и
    # конца(stop) типа Time
    # если даты не указаны получает за весь период
    def report(options = {})
      message = message_header
      unless options.empty?
        start, stop = options[:start].strftime(DATEFORMAT), options[:stop].strftime(DATEFORMAT)
        if start =~ DATEREGEXP and stop =~ DATEREGEXP
          message << <<-PERIOD
            <start>#{start}</start>
            <stop>#{stop}</stop>
          PERIOD
        else
          raise ArgumentError, "Date #{start} or date #{stop} is incorrect!"
        end
      end
      message << message_footer

      STDERR.puts "+SENDED:\n"+message+"\n-SENDED\n" if $DEBUG
      @connection.request_post('/report.xml', message) do |response|
        case response
        when Net::HTTPSuccess
          return ReportAnswer.new(response.body)
        else
          response.error!
        end
      end
    end

    # возвращает текущий баланс типа BalanceAnswer
    def balance
      message = message_header + message_footer
      STDERR.puts "+SENDED:\n"+message+"\n-SENDED\n" if $DEBUG
      @connection.request_post('/balance.xml', message) do |response|
        case response
        when Net::HTTPSuccess
          return BalanceAnswer.new(response.body)
        else
          response.error!
        end
      end
    end

    # отменяет СМС с идентификатором smsid
    def cancel(smsid)
      message = message_header
      message << <<END
<smsid>#{smsid}</smsid>
END
      message << message_footer
      STDERR.puts "+SENDED:\n"+message+"\n-SENDED\n" if $DEBUG
      @connection.request_post('/cancel.xml', message) do |response|
        case response
        when Net::HTTPSuccess
          return CancelAnswer.new(response.body)
        else
          response.error!
        end
      end
    end
  private

    # формирует заголовок с данными авторизации
    def message_header
      <<END
<data>
  <login>#{@login}</login>
  <password>#{@password}</password>
END
    end

    # формирует подвал запроса
    def message_footer
      "</data>"
    end
  end

end

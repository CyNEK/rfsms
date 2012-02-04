# encoding: utf-8
require 'spec_helper'

describe Rfsms::Connection do
  before(:all) do
    @connection = Rfsms::Connection.new('https://transport.rfsms.ru:7214', 'newcom', 'newc0w2m2')
  end
  
  describe "Метод send(message, phones)" do
    it "при отправке SMS по списку правильных номеров должен возвращать ответ (Rfsms::Answer)" do
      correct_phones = ['89123838878', '8-909-190-9409']
      send_answer = nil
      lambda { send_answer = @connection.send('test', correct_phones) }.should_not raise_error
      send_answer.should be_an_instance_of(Rfsms::SendAnswer)
    end

    it "должен вызывать исключение AnswerError, если все номера некорректны" do
      incorrect_phones = ['8912383887', '8-909-190-94097']
      lambda { @connection.send('test', incorrect_phones) }.should raise_error Rfsms::AnswerError
    end

    it "должен возвращать количество отправленных SMS соответствующее количеству корректных номеров" do
      correct_phones = ['89123838878', '8-909-190-9409']
      incorrect_phones = ['8912383887', '8-909-190-94097']
      answer = nil
      lambda { answer = @connection.send('test', incorrect_phones.concat(correct_phones)) }.should_not raise_error
      answer.col_send_abonent.should be == 2
    end
  end

  describe "Метод report(start, stop)" do
    it "должен получать список рассылки за определенный период при корректно указанных датах начала и конца" do
      start = Time.now - 2.hour
      correct_phones = ['89123838878']
      @connection.send('test', correct_phones).should be_an_instance_of(Rfsms::SendAnswer)
      stop = Time.now + 2.hour

      report = @connection.report(:start => start, :stop => stop)
      report.should be_an_instance_of(Rfsms::ReportAnswer)
      report.sms.size.should be > 0
    end

    it "должен получать список рассылки за весь период при неуказанных дате начала и конца" do
      # TODO: Исключить это дублирование
#      start = Time.now
#      correct_phones = ['89123838878']
#      @connection.send('test', correct_phones)
#      stop = Time.now
#
#      @connection.send('test2', correct_phones)
#
#      report_with_period = @connection.report(:start => start, :stop => stop)
#      report_with_period.should be_an_instance_of(Rfsms::ReportAnswer)
#
#      report = @connection.report
#      report.should be_an_instance_of(Rfsms::ReportAnswer)
#
#      report.sms.size.should be > report_with_period.sms.size
    end
  end

  describe "Метод balance()" do
    it "должен возвращать текущее значение баланса типа Float в поле account созданного объекта" do
      balance = nil
      lambda { balance = @connection.balance }.should_not raise_error
      balance.should be_an_instance_of(Rfsms::BalanceAnswer)
      balance.account.should be_an_instance_of(Float)
    end
  end

  describe "Метод cancel(smsid)" do
    it "должен отменять отложенную SMS (группу SMS) с идентификатором smsid и возвращать Rfsms::CancelAnswer" do
      send_answer = @connection.send(
        "Проверка отмены рассылки",
        ['89123838878'],
        Time.now + 1.hour
      )
      canceled = @connection.cancel(send_answer.smsid)
      canceled.should be_an_instance_of(Rfsms::CancelAnswer)
      canceled.cancel_col.should be > 0
    end
  end
end
# encoding: utf-8
require 'spec_helper'

describe Rfsms::SendAnswer do
  before(:each) do
    # Элементы ответа от сервера при отправке 2 правильных sms
    @correct_answer_body_for_2sms = <<-ANSWER
      <data>
        <code>1</code>
        <descr>Операция успешно завершена</descr>
        <smsid>un1quine221d</smsid>
        <datetime>#{Time.now.strftime(DATETIME_FORMAT)}</datetime>
        <action>send</action>
        <allRecivers>2</allRecivers>
        <colSendAbonent>2</colSendAbonent>
        <colNonSendAbonent>0</colNonSendAbonent>
        <priceOfSending>0.76</priceOfSending>
        <colsmsOfSending>2</colsmsOfSending>
        <price>0.38</price>
      </data>
    ANSWER
    @correct_answer_elements_for_2sms = Nori.parse(@correct_answer_body_for_2sms, :nokogiri)[:data]
  end

  describe "конструктор" do
    it "при корректных входных данных должен создавать экземпляр с соответствующими входу полями" do
      send_answer = Rfsms::SendAnswer.new(@correct_answer_body_for_2sms)
      send_answer.should be_an_instance_of(Rfsms::SendAnswer)
      send_answer.descr.should be == @correct_answer_elements_for_2sms[:descr]
      send_answer.smsid.should be == @correct_answer_elements_for_2sms[:smsid]
      send_answer.datetime.should be == DateTime.strptime(@correct_answer_elements_for_2sms[:datetime], DATETIME_FORMAT)
      send_answer.action.should be == @correct_answer_elements_for_2sms[:action]
      send_answer.all_recivers.should be == @correct_answer_elements_for_2sms[:all_recivers].to_i
      send_answer.col_send_abonent.should be == @correct_answer_elements_for_2sms[:col_send_abonent].to_i
      send_answer.col_non_send_abonent.should be == @correct_answer_elements_for_2sms[:col_non_send_abonent].to_i
      send_answer.price_of_sending.should be == @correct_answer_elements_for_2sms[:price_of_sending].to_f
      send_answer.colsms_of_sending.should be == @correct_answer_elements_for_2sms[:colsms_of_sending].to_i
      send_answer.price.should be == @correct_answer_elements_for_2sms[:price].to_f
    end

    it "при значении элемента code отличного от 1 должен вызывать исключение Rfsms::AnswerError" do
      lambda do
        Rfsms::SendAnswer.new(@correct_answer_body_for_2sms.gsub(%r{(?<=<code>).*(?=</code>)}, '500'))
      end.should raise_error Rfsms::AnswerError
    end

    it "при отсутствии любого из входных данных должен вызывать исключение Rfsms::IncorrectAnswerError" do
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<code>.*</code>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error(Rfsms::IncorrectAnswerError)
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<descr>.*</descr>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error Rfsms::IncorrectAnswerError
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<smsid>.*</smsid>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error Rfsms::IncorrectAnswerError
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<datetime>.*</datetime>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error Rfsms::IncorrectAnswerError
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<action>.*</action>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error Rfsms::IncorrectAnswerError
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<allRecivers>.*</allRecivers>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error Rfsms::IncorrectAnswerError
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<colSendAbonent>.*</colSendAbonent>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error Rfsms::IncorrectAnswerError
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<colNonSendAbonent>.*</colNonSendAbonent>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error Rfsms::IncorrectAnswerError
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<priceOfSending>.*</priceOfSending>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error Rfsms::IncorrectAnswerError
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<colsmsOfSending>.*</colsmsOfSending>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error Rfsms::IncorrectAnswerError
      lambda do
        incorrect_elements = @correct_answer_body_for_2sms.gsub(%r{<price>.*</price>}, '')
        Rfsms::SendAnswer.new(incorrect_elements)
      end.should raise_error Rfsms::IncorrectAnswerError
    end
  end
end


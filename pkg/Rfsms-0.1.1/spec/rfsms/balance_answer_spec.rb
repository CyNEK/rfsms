# encoding: utf-8
require 'spec_helper'

describe Rfsms::BalanceAnswer do
  before(:each) do
    @correct_body = <<-ANSWER
      <data>
        <code>1</code>
        <descr>Операция успешно завершена</descr>
        <account>10000.94</account>
      </data>
    ANSWER
    @correct_elements = Nori.parse(@correct_body, :nokogiri)['data']
  end

  it "при корректных входных данных конструктор создает объект с соответствующими входу полями" do
    correct_balance_answer = Rfsms::BalanceAnswer.new(@correct_body)
    correct_balance_answer.should be_an_instance_of(Rfsms::BalanceAnswer)
    correct_balance_answer.descr.should be == @correct_elements['descr']
    correct_balance_answer.account.should be == @correct_elements['account'].to_f
  end

  it "при отсутствии одного из входных элементов конструктор вызывает исключение Rfsms::IncorrectAnswerError" do
    lambda do
      incorrect_elements = @correct_body.gsub(%r{<code>.*</code>}, '')
      Rfsms::BalanceAnswer.new(incorrect_elements)
    end.should raise_error(Rfsms::IncorrectAnswerError)
    lambda do
      incorrect_elements = @correct_body.gsub(%r{<descr>.*</descr>}, '')
      Rfsms::BalanceAnswer.new(incorrect_elements)
    end.should raise_error(Rfsms::IncorrectAnswerError)
    lambda do
      incorrect_elements = @correct_body.gsub(%r{<account>.*</account>}, '')
      Rfsms::BalanceAnswer.new(incorrect_elements)
    end.should raise_error(Rfsms::IncorrectAnswerError)
  end
end


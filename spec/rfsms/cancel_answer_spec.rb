# encoding: utf-8
require 'spec_helper'

describe Rfsms::CancelAnswer do
  before(:each) do
    @correct_body = <<-ANSWER
      <data>
        <code>1</code>
        <descr>Операция завершена успешно</descr>
        <action>make</action>
      </data>
    ANSWER
    @correct_elements = Nori.parse(@correct_body, :nokogiri)['data']
  end

  describe "конструктор" do
    it "при корректных входных данных создает экземпляр ответа с соответствующими входу полями" do
      cancel_answer = Rfsms::CancelAnswer.new(@correct_body)
      cancel_answer.should be_an_instance_of(Rfsms::CancelAnswer)
      cancel_answer.descr.should be == @correct_elements['descr']
      cancel_answer.action.should be == @correct_elements['action']
    end

    it "при отсутствии одного из входных элементов вызывает исключение Rfsms::IncorrectAnswerError" do
      lambda do
        incorrect_elements = @correct_body.gsub(%r{<code>\d+</code>}, '')
        Rfsms::CancelAnswer.new(incorrect_elements)
      end.should raise_error(Rfsms::IncorrectAnswerError)
      lambda do
        incorrect_elements = @correct_body.gsub(%r{<descr>.+</descr>}, '')
        Rfsms::CancelAnswer.new(incorrect_elements)
      end.should raise_error(Rfsms::IncorrectAnswerError)
      lambda do
        incorrect_elements = @correct_body.gsub(%r{<action>.+</action>}, '')
        Rfsms::CancelAnswer.new(incorrect_elements)
      end.should raise_error(Rfsms::IncorrectAnswerError)
    end

    it "при значении входного элемента action отличного от make или check вызывает исключение Rfsms::IncorrectAnswerError" do
      lambda do
        Rfsms::CancelAnswer.new(@correct_body.gsub(%r{(?<=<action>).+(?=</action>)}, 'make'))
      end.should_not raise_error(Rfsms::IncorrectAnswerError)
      lambda do
        Rfsms::CancelAnswer.new(@correct_body.gsub(%r{(?<=<action>).+(?=</action>)}, 'check'))
      end.should_not raise_error(Rfsms::IncorrectAnswerError)
      lambda do
        Rfsms::CancelAnswer.new(@correct_body.gsub(%r{(?<=<action>).+(?=</action>)}, 'incorrect'))
      end.should raise_error(Rfsms::IncorrectAnswerError)
    end
  end
end


# encoding: utf-8
require 'spec_helper'

describe Rfsms::Answer do
  before(:each) do
    @correct_body = <<-ANSWER
      <data>
        <code>1</code>
        <descr>Операция успешно завершена</descr>
      </data>
    ANSWER
    @correct_elements = Nori.parse(@correct_body, :nokogiri)['data']
  end

  describe "конструктор" do
    it "при корректных входных данных должен создавать экземпляр с соответствующими входу полями" do
      answer = Rfsms::Answer.new(@correct_body)
      answer.should be_an_instance_of(Rfsms::Answer)
      answer.descr.should be == @correct_elements['descr']
    end

    it "при значении элемента code отличного от 1 должен вызывать исключение Rfsms::AnswerError" do
      lambda do
        Rfsms::Answer.new(@correct_body.gsub(%r{(?<=<code>)\d+(?=</code>)}, '500'))
      end.should raise_error Rfsms::AnswerError
    end

    it "при отсутствии одного из входных элементов вызывает исключение Rfsms::IncorrectAnswerError" do
      lambda do
        incorrect_elements = @correct_body.gsub(%r{<code>.*</code>}, '')
        Rfsms::Answer.new(incorrect_elements)
      end.should raise_error(Rfsms::IncorrectAnswerError)
      lambda do
        incorrect_elements = @correct_body.gsub(%r{<descr>.*</descr>}, '')
        Rfsms::Answer.new(incorrect_elements)
      end.should raise_error(Rfsms::IncorrectAnswerError)
    end
  end
end


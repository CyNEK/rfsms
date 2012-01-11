# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'rake'
require 'rake/clean'
#require 'rake/rdoctask'
#require 'rdoc/task'
require 'rake/testtask'
require 'rspec/core/rake_task'

#Rake::RDocTask.new do |rdoc|
#  files =['README', 'LICENSE', 'lib/**/*.rb']
#  rdoc.rdoc_files.add(files)
#  rdoc.main = "README" # page to start on
#  rdoc.title = "Rfsms Docs"
#  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
#  rdoc.options << '--line-numbers'
#end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

RSpec::Core::RakeTask.new do |spec|
  spec.pattern = 'spec/**/*.rb'
  spec.rspec_opts = ['--backtrace']
end

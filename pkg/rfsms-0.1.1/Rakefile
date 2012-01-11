# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
#require 'rake/rdoctask'
#require 'rdoc/task'
require 'rake/testtask'
#require 'spec/rake/spectask'
require 'rspec/core/rake_task'

spec = Gem::Specification.new do |s|
  s.name = 'rfsms'
  s.version = '0.1.1'
  s.has_rdoc = false
#  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = <<END
rfsms is sender SMS via rfsms.ru
END
  s.description = s.summary
  s.author = 'Danil Korotaev'
  s.email = 'greyd@mail333.com'
  # s.executables = ['your_executable_here']
  s.files = %w(Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
  s.add_dependency 'nokogiri', ">=1.5.0"
  s.add_dependency 'nori', ">=1.0.2"
  s.add_dependency 'activesupport', ">=3.1.1"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

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

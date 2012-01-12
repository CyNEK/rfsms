Gem::Specification.new do |s|
  s.name        = 'rfsms'
  s.version     = '0.1.2'
  s.date        = '2012-01-11'
  s.summary     = "rfsms is sender SMS via rfsms.ru"
  s.authors     = ['Danil Korotaev']
  s.email = 'greyd@mail333.com'
  s.files = %w(Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.homepage    =
    'http://rubygems.org/gems/rfsms'
  s.add_dependency 'nokogiri', ">=1.5.0"
  s.add_dependency 'nori', ">=1.0.2"
  s.add_dependency 'activesupport', ">=3.1.1"
  s.description = "Sender SMS via rfsms.ru"
end

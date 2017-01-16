Gem::Specification.new do |s|
  s.name        = 'calx_client'
  s.version     = '0.0.1'
  s.date        = '2016-12-09'
  s.summary     = 'CalX API Client'
  s.description = 'API client to access CalX events'
  s.authors     = ['Mert Guldur']
  s.email       = 'mertguldur@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.license     = 'MIT'

  s.add_dependency 'api-auth'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'api-auth'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'rubocop'
end

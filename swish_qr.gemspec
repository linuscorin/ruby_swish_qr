Gem::Specification.new do |s|
  s.name        = 'swish_qr'
  s.version     = '0.0.0'
  s.date        = '2017-11-09'
  s.summary     = 'QR code generator for Swish'
  s.description = 'An interface for the public Swish QR API'
  s.authors     = ['Linus Corin']
  s.email       = ['noreply+see_website_for_email@corin.net']
  s.files       = ['lib/swish_qr.rb']
  s.homepage    = 'http://rubygems.org/gems/swish_qr'
  s.license     = 'MIT'
  s.add_runtime_dependency 'httparty', '~> 0'
  s.add_development_dependency 'httparty', '~> 0'
  s.add_development_dependency 'rspec', '~> 0'
  s.add_development_dependency 'rake', '~> 0'
  s.add_development_dependency 'vcr', '~> 0'
end

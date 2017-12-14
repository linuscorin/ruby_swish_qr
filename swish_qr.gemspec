Gem::Specification.new do |s|
  s.name        = 'swish_qr'
  s.version     = '0.0.4'
  s.date        = '2017-12-12'
  s.summary     = 'QR code and URI generator for Swish'
  s.description = 'An interface for the public Swish QR API, and generator of Swish payment URIs'
  s.authors     = ['Linus Corin']
  s.email       = ['noreply+see_website_for_email@corin.net']
  s.files       = ['lib/swish_qr.rb']
  s.homepage    = 'https://github.com/linuscorin/ruby_swish_qr'
  s.license     = 'MIT'
  s.add_runtime_dependency 'httparty', '~> 0.15'
  s.add_development_dependency 'httparty', '~> 0.15'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'vcr', '~> 4.0'
end

#coding: utf-8

Gem::Specification.new do |s|
  s.name          = 'pmf_nfpse_generator'
  s.version       = '0.0.4'
  s.date          = '2014-04-06'
  s.summary       = "PMF (SC) NFPS-e Generator"
  s.description   = "A gem to generate NFPS-e XML's of Florianópolis, SC, Brazil"
  s.authors       = ["Pedro Bachiega"]
  s.email         = 'pedro@pedrobachiega.com'
  s.files         = ["lib/cidades_brasil.csv", "lib/pmf_nfpse_generator.rb"]
  # s.files         += Dir['config/**/*']
  # s.require_paths = %w[lib config]
  s.homepage      = 'https://github.com/ResultadosDigitais/pmf_nfpse_generator'
  s.license       = 'MIT'

  # s.add_runtime_dependency "csv"
  s.add_runtime_dependency "builder"
  s.add_runtime_dependency "httparty"
  s.add_runtime_dependency "i18n"
  s.add_runtime_dependency "activemodel"

  s.add_development_dependency "bundler", "~> 1.9"
  s.add_development_dependency "rake", "~> 10.4"
  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
end

#coding: utf-8

Gem::Specification.new do |s|
  s.name          = 'pmf_nfpse_generator'
  s.version       = '0.0.2'
  s.date          = '2014-04-06'
  s.summary       = "PMF (SC) NFPS-e Generator"
  s.description   = "A gem to generate NFPS-e XML's of Florianópolis, SC, Brazil"
  s.authors       = ["Pedro Bachiega"]
  s.email         = 'pedro@pedrobachiega.com'
  s.files         = ["lib/cidades_brasil.csv", "lib/pmf_nfpse_generator.rb"]
  # s.files         += Dir['config/**/*']
  # s.require_paths = %w[lib config]
  s.homepage      = 'https://github.com/pedrobachiega/pmf_nfpse_generator'
  s.license       = 'MIT'

  # s.add_runtime_dependency "csv"
  s.add_runtime_dependency "builder"
  s.add_runtime_dependency "httparty"
end
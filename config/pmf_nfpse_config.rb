#coding: utf-8

PmfNfpseGenerator.configure do |config|
  config.TipoSistema = "1"

  config.Emissor_Identificacao = "X542H1"
  config.Emissor_AEDF = "578256"
  config.Emissor_TipoAedf = "NORMAL"

  config.Emissor_Cidade = "Florianópolis"
  config.Emissor_Estado = "SC"

  config.Impostos = { :pis => 0.0065, :cofins => 0.03, :iss => 0.02, :cprb => 0.02 };
end

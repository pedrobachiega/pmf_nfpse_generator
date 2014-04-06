# PMF NFPS-e Generator

[pt_BR] Gema para gerar XML's da [NFPS-e de Florianópolis, SC](http://www.pmf.sc.gov.br/sites/notaeletronica/) - Brasil
[en] A gem to generate NFPS-e XML's of Florianópolis, SC - Brazil

## Uso

Crie um CSV com os dados de emissão no formato abaixo:
```CSV
"Data","CPF_CNPJ","Nome_RazaoSocial","Endereco","Cidade","CEP","Estado","Email","Valor_Produto","Valor_Consultoria","Valor_Outros","Valor_Cursos","Valor_Eventos","CST","ExtraInfo"
"17/March/2014 21:36","747.268.945-52","Frederico Josué","Rua Dr. Jose Borges, 734, apto 909","Natal","59056-040","RN","fredericojosue@gmail.com","R$ 99,00",2000,,,,0,"NF já está paga"
03/01/13,"17.755.687/0001-42","INSTITUTO GRANDE FLORIPA","Rua Mauro Ramos, 683 - sala 935","Florianópolis","88010-030","SC","ana@institutofloripa.org.br","173,4",,,"199",,0,"Observação para NF"
```

Configure os dados para emissão:
```Ruby
PmfNfpseGenerator.configure do |config|
  config.TipoSistema = "1"                   # "0" para homologação, "1" para produção

  config.Emissor_Identificacao = "M9D2N0"
  config.Emissor_AEDF = "415512"
  config.Emissor_TipoAedf = "NORMAL"

  config.Emissor_Cidade = "Florianópolis"
  config.Emissor_Estado = "SC"
end
```

Chame o gerador passando o csv:
```Ruby
PmfNfpseGenerator.create_nfpse_xmls_from_csv_file("res/faturas.csv")
```

Os arquivos XML's vão ser gerados na pasta "out/".

#coding: utf-8

require 'csv'
require 'builder'
require 'httparty'

module PmfNfpseGenerator

  class << self
    attr_accessor :config
    attr_accessor :cities
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config)
  end

  class Configuration
    attr_accessor :TipoSistema, :Emissor_Identificacao, :Emissor_AEDF, :Emissor_TipoAedf, :Emissor_Cidade, :Emissor_Estado, :Impostos
  end


  def self.create_nfpse_xmls_from_csv_file(file = "res/invoices.csv")
    contents = File.read(file)
    create_nfpse_xmls_from_csv(contents)

    true
  end

  def self.create_nfpse_xmls_from_csv(contents)
    count_total = 0
    count_errors = 0
    items = parse(contents)
    items.each_with_index do |row, i| 
      count_total = count_total + 1
      begin
        create_nfpse_xml(row, i)
      rescue => e
        count_errors = count_errors + 1
        p "--------------"
        p "#{i} : #{row}"
        p e
        p "--------------"
      end
    end
    p "Total: #{count_total} / #{count_errors} erros"

    true
  end

  def self.create_nfpse_xml(content, outname = "")
    xml = gen_xml(content)
    dir = (config.TipoSistema=="1" ? "producao" : "homologacao")
    File.open("#{dir}/#{outname.to_s.rjust(10, '0')}.xml", 'w') {|f| f.write(xml) }
  end

  def self.gen_xml(content)
    # {"city"=>"Curitiba", "state"=>"PR", "city_ibge_code"=>"4106902", "source"=>"csv"}
    city = get_city_info(content['zipcode'].gsub(".",""), content['state'], content['city'])
    cst = (content['cst'].nil? || content['cst'].empty?) ? "0" : content['cst']

    date = ""
    if content['billing_date'].respond_to?(:strftime)
      date = content['billing_date']
      now = DateTime.strptime("#{DateTime.now.day}/#{DateTime.now.month}/#{DateTime.now.year}", '%d/%m/%Y')
      raise "Date at the future" if date != now && date > now
      date = date.strftime('%Y-%m-%d')
    end

    email = content['email'].split(",")[0]

    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.instruct! :xml, :encoding => "UTF-8"
    xml.InfRequisicao("xmlns" => "http://nfe.pmf.sc.gov.br/nfse/versao?tipo=xsd-2_0", "xmlns:dsig" => "http://www.w3.org/2000/09/xmldsig") do |root|
      root.Versao "2.0"
      root.TipoSistema "#{config.TipoSistema}"
      root.Identificacao "#{config.Emissor_Identificacao}"
      root.AEDF do |aedf|
        aedf.AEDF "#{config.Emissor_AEDF}"
        aedf.TipoAedf "#{config.Emissor_TipoAedf}"
      end
      root.DataEmissao "#{date}Z"

      if city["city"] == "#{config.Emissor_Cidade}"
        root.CFPS "9201"
      elsif city["state"] == "#{config.Emissor_Estado}"
        root.CFPS "9202"
      else
        root.CFPS "9203"
      end

      root.DadosServico do |servicos|

        issqn = 0
        total = 0

        if !(content['price_product'].nil? || content['price_product'].empty?) && content['price_product'].gsub("R$", "").to_i != 0
          price = content['price_product'].gsub("R$", "").gsub(" ", "").gsub(",", ".").to_f
          aliquota = 0.02
          issqn += (price * aliquota).round(2)
          total += price
          servicos.ItemServico do |item| 
            item.IdCNAE "9178"
            item.CodigoAtividade "6203100"
            item.DescricaoServico "SERVIÇO DE DESENVOLVIMENTO E LICENCIAMENTO DE PROGRAMA DE MARKETING DIGITAL - RD STATION"
            item.CST cst
            item.Aliquota aliquota
            item.ValorUnitario price
            item.Quantidade "1"
            item.ValorTotal price
          end
        end
        if !(content['price_others'].nil? || content['price_others'].empty?) && content['price_others'].gsub("R$", "").to_i != 0
          price = content['price_others'].gsub("R$", "").gsub(" ", "").gsub(",", ".").to_f
          aliquota = 0.02
          issqn += (price * aliquota).round(2)
          total += price
          servicos.ItemServico do |item| 
            item.IdCNAE "9179"
            item.CodigoAtividade "6201500"
            item.DescricaoServico "SERVIÇO DE DESENVOLVIMENTO E SUPORTE DE MARKETING DIGITAL"
            item.CST cst
            item.Aliquota aliquota
            item.ValorUnitario price
            item.Quantidade "1"
            item.ValorTotal price
          end
        end

        if !(content['price_consultancy'].nil? || content['price_consultancy'].empty?) && content['price_consultancy'].gsub("R$", "").to_i != 0
          price = content['price_consultancy'].gsub("R$", "").gsub(" ", "").gsub(",", ".").to_f
          aliquota = 0.02
          issqn += (price * aliquota).round(2)
          total += price
          servicos.ItemServico do |item| 
            item.IdCNAE "9177"
            item.CodigoAtividade "6204000"
            item.DescricaoServico "CONSULTORIA EM TECNOLOGIA DA INFORMAÇÃO E MARKETING DIGITAL - RD STATION"
            item.CST cst
            item.Aliquota aliquota
            item.ValorUnitario price
            item.Quantidade "1"
            item.ValorTotal price
          end
        end
        if !(content['price_courses'].nil? || content['price_courses'].empty?) && content['price_courses'].gsub("R$", "").to_i != 0
          price = content['price_courses'].gsub("R$", "").gsub(" ", "").gsub(",", ".").to_f
          aliquota = 0.02
          issqn += (price * aliquota).round(2)
          total += price
          servicos.ItemServico do |item| 
            item.IdCNAE "9177"
            item.CodigoAtividade "6204000"
            item.DescricaoServico "MARKETING DIGITAL"
            item.CST cst
            item.Aliquota aliquota
            item.ValorUnitario price
            item.Quantidade "1"
            item.ValorTotal price
          end
        end
        if !(content['price_events'].nil? || content['price_events'].empty?) && content['price_events'].gsub("R$", "").to_i != 0
          price = content['price_events'].gsub("R$", "").gsub(" ", "").gsub(",", ".").to_f
          aliquota = 0.02
          issqn += (price * aliquota).round(2)
          total += price
          servicos.ItemServico do |item| 
            item.IdCNAE "9177"
            item.CodigoAtividade "6204000"
            item.DescricaoServico "MARKETING DIGITAL"
            item.CST cst
            item.Aliquota aliquota
            item.ValorUnitario price
            item.Quantidade "1"
            item.ValorTotal price
          end
        end

        servicos.BaseCalculo total.round(2)
        servicos.ValorISSQN issqn.round(2)
        servicos.ValorTotalServicos total.round(2)

        extra_info = content['extra_info']
        # CSRF (4,65%)
        if total > 5000
          csrf = (total*0.0465).round(2).to_s.gsub(".", ",")
          extra_info = "#{extra_info}
CSRF (4,65%): R$ #{csrf}"
        end
        # IRRF (1,5%)
        if total > 666.66
          ir = (total*0.015).round(2).to_s.gsub(".", ",")
          extra_info = "#{extra_info}
IRRF (1,5%): R$ #{ir}"
        end

        # config.Impostos = { :pis => 0.0065; :cofins => 0.03; :iss => 0.02; :cprb => 0.02 }
        taxesV = config.Impostos[:pis] + config.Impostos[:cofins] + config.Impostos[:iss] + config.Impostos[:cprb]
        taxesS = (total*taxesV).round(2).to_s.gsub(".", ",")
        taxesV = (taxesV*100).round(2).to_s.gsub(".", ",")

        extra_info = "#{extra_info}

Conforme lei federal 12.741/2012 da transparência, total impostos pagos R$ #{taxesS} (#{taxesV}%)"

        servicos.DadosAdicionais extra_info
      end
      root.Tomador do |tomador|
        tomador.IdentificacaoTomador do |identificacao|
          identificacao.DocIdTomador do |doc|
            cpf_cnpj = content['cpf_cnpj'].gsub(".", "").gsub("/", "").gsub("-", "").gsub("_", "").gsub(" ", "")

            #TODO
            doc.CPFCNPJ do |cpfcnpj|
              if (cpf_cnpj.size == 14)
                cpfcnpj.CNPJ cpf_cnpj
              elsif (cpf_cnpj.size == 11)
                cpfcnpj.CPF cpf_cnpj
              else
                raise "Incorrect CPF or CNPJ '#{cpf_cnpj}'"
              end
            end
          end # doc
        end # identificacao

        tomador.RazaoSocial content['name'][0..79]
        tomador.Endereco do |endereco|
          endereco.Logradouro content['address'][0..79]
          endereco.Bairro ""
          endereco.Municipio do |municipio| 
            municipio.CodigoMunicipio city["city_ibge_code"]
          end
          endereco.CodigoPostal do |codPostal|
            codPostal.CEP content['zipcode'].gsub(".", "").gsub("/", "").gsub("-", "").gsub(" ", "")
          end
          endereco.UF content['state'].gsub(" ", "")
        end # endereço
        tomador.Contato do |contato|
          contato.Email email[0..79]
        end

      end # tomador
    end # root
  end

  private

  def self.parse(contents)
    # contents = EncodingConverter.convert(contents)
    parsed_file = CSV.parse(contents, { :col_sep => "," })

    list = []
    parsed_file[0].each_with_index do |column, i|
      if(column)
        column = column.downcase
        
        if column == "data" || column == "data emissão"
          list << "billing_date"

        elsif column == "cnpj" || column == "cpf" || column == "cpf_cnpj" || column == "cnpj_cpf"
          list << "cpf_cnpj"

        elsif column == "nome completo" || column == "nome" || column == "razao social" || column == "nome_razaosocial" || column == "nome_razao_social"
          list << "name"

        elsif column == "endereço" || column == "endereco"
          list << "address"
        elsif column == "cidade"
          list << "city"
        elsif column == "cep"
          list << "zipcode"
        elsif column == "estado"
          list << "state"

        elsif column == "email"
          list << "email"

        elsif column == "cfps"
          list << "cfps"

        elsif column == "valor_produto" || column == "produto" || column == "valor produto"
          list << "price_product"
        elsif column == "valor_consultoria" || column == "consultoria" || column == "valor consultoria"
          list << "price_consultancy"
        elsif column == "valor_outros" || column == "outros" || column == "valor outros"
          list << "price_others"
        elsif column == "valor_cursos" || column == "curso" || column == "valor cursos"
          list << "price_courses"
        elsif column == "valor_eventos" || column == "eventos" || column == "valor eventos"
          list << "price_events"

        elsif column == "cst"
          list << "cst"

        elsif column == "extrainfo" || column == "extra_info"
          list << "extra_info"

        else
          list << column.downcase
        end
      end
    end

    rows = Array.new
    parsed_file[1..-1].each_with_index do |row, i|
      unless (row[0].nil? || row[0].empty?)
        row_map = {}
        row.each_with_index do |value, index|
          if list[index] == "billing_date"
            begin
              value = DateTime.strptime(value, '%d/%b/%Y')
            rescue => e
              value = (value.size == 10) ? DateTime.strptime(value, '%d/%m/%Y') : DateTime.strptime(value, '%d/%m/%y')
            end
            row_map[list[index]] = value || ""
          else
            row_map[list[index]] = value || ""
          end
        end

        rows << row_map
      end
    end

    rows
  end

  def self.get_city_info(cep, state = "", cityname = "")
    state.strip!
    cityname.strip!
    cityname = (cityname.downcase == "brasilia") ? "brasília" : cityname
    cityname = (cityname.downcase == "sao paulo") ? "são paulo" : cityname

    city_info = self.get_cities[state.downcase][cityname.downcase]
    if city_info
      { "city" => city_info["Nome_Município"], "state" => city_info["UF"], "city_ibge_code" => city_info["UF_MUNIC"], "source" => "csv" }
    else
      cep.strip!
      cep = cep.gsub(".", "").gsub("/", "").gsub("-", "").gsub(" ", "")
      response = HTTParty.get("http://api.postmon.com.br/v1/cep/#{cep}")
      resp = response.parsed_response
      { "city" => resp["cidade"], "state" => resp["estado"], "city_ibge_code" => resp["cidade_info"]["codigo_ibge"], "source" => "postmon" }
    end
  end

  def self.get_cities
    self.cities ||= self.load_cities
  end

  def self.load_cities
    contents =  File.read(self.filepath('cidades_brasil.csv'))
    lines_parsed = CSV.parse(contents, { :col_sep => "," })
    # UF,UF_MUNIC,Nome_Município

    list = {}
    lines_parsed.each_with_index do |line, i|
      if (i > 0 && !line.empty?)
        list[line[0].downcase] = {} if list[line[0].downcase] == nil
        list[line[0].downcase][line[2].downcase] = { "UF" => line[0], "UF_MUNIC" => line[1], "Nome_Município" => line[2] }
      end
    end
    list
  end

  def self.filepath(filename)
    File.join(File.dirname(File.expand_path(__FILE__)), filename)
  end

end

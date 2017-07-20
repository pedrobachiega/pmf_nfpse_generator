require 'spec_helper'
require 'active_support/all'

describe PmfNfpseGenerator do
  let(:items) { [{ price: 919, cnae_id: '9178', cnae_code: '6203100', cnae_desc: 'SERVIÇO DE LICENCIAMENTO DE PROGRAMA DE MARKETING DIGITAL - RD STATION', cnae_aliquota: 0.02, cst: '0' }] }
  let(:attrs) do
    {
      billing_date: '01/01/2015',
      cpf_cnpj: '00.000.000/0000-00',
      name: 'name',
      address: 'address',
      city: 'Florianópolis',
      zipcode: '88062365',
      state: 'SC',
      email: 'email',
      cfps: 'cfps',
      cst: 'cst',
      extra_info: 'extra_info',
      csrf: 1,
      irrf: 1,
      items: items
    }
  end
  let(:lib) { PmfNfpseGenerator.new(attrs) }

  describe '#to_xml' do
    before(:each) do
      lib.configure do |config|
        config.TipoSistema = '1'

        config.Emissor_Identificacao = 'X542H1'
        config.Emissor_AEDF = '578256'
        config.Emissor_TipoAedf = 'NORMAL'

        config.Emissor_Cidade = 'Florianópolis'
        config.Emissor_Estado = 'SC'

        config.Impostos = { pis: 0.0065, cofins: 0.03, iss: 0.02, cprb: 0.02 }
      end
    end

    it 'generate a xml' do
      VCR.use_cassette('to_xml') do
        expect(lib.to_xml).to be
      end
    end

    describe 'validate' do
      let(:invalid_lib) { PmfNfpseGenerator.new(invalid_attrs) }

      context 'without zipcode' do
        let(:invalid_attrs) { attrs.merge(zipcode: nil) }

        it do
          expect(invalid_lib.to_xml).to be_falsey
          expect(invalid_lib.errors[:zipcode].size).to eq(1)
        end
      end

      context 'without cpf_cnpj' do
        let(:invalid_attrs) { attrs.merge(cpf_cnpj: nil) }

        it do
          expect(invalid_lib.to_xml).to be_falsey
          expect(invalid_lib.errors[:cpf_cnpj].size).to eq(1)
        end
      end

      context 'without state' do
        let(:invalid_attrs) { attrs.merge(state: nil) }

        it do
          VCR.use_cassette('to_xml_validate_without_state') do
            expect(invalid_lib.to_xml).to be_falsey
            expect(invalid_lib.errors[:state].size).to eq(1)
          end
        end
      end

      context 'without city' do
        let(:invalid_attrs) { attrs.merge(city: nil) }

        it do
          VCR.use_cassette('to_xml_validate_without_city') do
            expect(invalid_lib.to_xml).to be_falsey
            expect(invalid_lib.errors[:city].size).to eq(1)
          end
        end
      end

      context 'without billing_date' do
        let(:invalid_attrs) { attrs.merge(billing_date: nil) }

        it do
          expect(invalid_lib.to_xml).to be_falsey
          expect(invalid_lib.errors[:billing_date].size).to eq(1)
        end
      end

      context 'without email' do
        let(:invalid_attrs) { attrs.merge(email: nil) }

        it do
          expect(invalid_lib.to_xml).to be_falsey
          expect(invalid_lib.errors[:email].size).to eq(1)
        end
      end

      context 'without name' do
        let(:invalid_attrs) { attrs.merge(name: nil) }

        it do
          expect(invalid_lib.to_xml).to be_falsey
          expect(invalid_lib.errors[:name].size).to eq(1)
        end
      end

      context 'without address' do
        let(:invalid_attrs) { attrs.merge(address: nil) }

        it do
          expect(invalid_lib.to_xml).to be_falsey
          expect(invalid_lib.errors[:address].size).to eq(1)
        end
      end

      context 'invalid cpf_cnpj' do
        it do
          lib.cpf_cnpj = '000'
          VCR.use_cassette('to_xml_invalid_cpf_cnpj') do
            expect(lib.to_xml).to be_falsey
          end
          expect(lib.errors[:cpf_cnpj].size).to eq(1)
        end
      end

      context 'invalid billing_date' do
        it do
          lib.billing_date = "#{1.day.from_now.day}/#{1.day.from_now.month}/#{1.day.from_now.year}"
          VCR.use_cassette('to_xml_invalid_cpf_cnpj') do
            expect(lib.to_xml).to be_falsey
          end
          expect(lib.errors[:billing_date].size).to eq(1)
        end
      end
    end
  end

  describe '#zipcode_strip' do
    it do
      zip_actual = '88.05/1 - 0.0.0  '
      zip_expected = '88051000'
      expect(lib.send(:zipcode_strip, zip_actual)).to eq(zip_expected)
    end
  end
end

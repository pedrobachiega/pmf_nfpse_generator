require 'spec_helper'

describe PmfNfpseGenerator do

  let(:attrs) do
     {
       billing_date: Time.parse("2015-01-01"),
       cpf_cnpj: "00.000.000/0000-00",
       name: "name",
       address: "address",
       city: "city",
       zipcode: "88062365",
       state: "sc",
       email: "email",
       cfps: "cfps",
       price_product: "price_product",
       price_consultancy: "price_consultancy",
       price_others: "price_others",
       price_courses: "price_courses",
       price_events: "price_events",
       cst: "cst",
       extra_info: "extra_info"
     }
  end
  let(:lib) { PmfNfpseGenerator.new(attrs) }

   describe "#to_xml!" do
     before(:each) do
       lib.configure do |config|
         config.TipoSistema = "1"

         config.Emissor_Identificacao = "X542H1"
         config.Emissor_AEDF = "578256"
         config.Emissor_TipoAedf = "NORMAL"

         config.Emissor_Cidade = "Florianópolis"
         config.Emissor_Estado = "SC"

         config.Impostos = { :pis => 0.0065, :cofins => 0.03, :iss => 0.02, :cprb => 0.02 };
       end
     end

     it "generate a xml" do
       VCR.use_cassette('to_xml') do
         expect(lib.to_xml!).to be
       end
     end

     describe "validate" do

       let(:invalid_lib) { PmfNfpseGenerator.new }

       it "without zipcode" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:zipcode].size).to eq(1)
       end

       it "without cpf_cnpj" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:cpf_cnpj].size).to eq(1)
       end

       it "without state" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:state].size).to eq(1)
       end

       it "without city" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:city].size).to eq(1)
       end

       it "cst city" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:city].size).to eq(1)
       end

       it "cst billing_date" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:billing_date].size).to eq(1)
       end

       it "cst email" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:email].size).to eq(1)
       end

       it "cst price_product" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:price_product].size).to eq(1)
       end

       it "cst price_others" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:price_others].size).to eq(1)
       end

       it "cst price_consultancy" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:price_consultancy].size).to eq(1)
       end

       it "cst price_courses" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:price_courses].size).to eq(1)
       end

       it "cst price_events" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:price_events].size).to eq(1)
       end

       it "cst extra_info" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:extra_info].size).to eq(1)
       end

       it "cst name" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:name].size).to eq(1)
       end

       it "cst address" do
         expect(invalid_lib.to_xml!).to be_falsey
         expect(invalid_lib.errors[:address].size).to eq(1)
       end

     end
   end

end

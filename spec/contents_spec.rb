require 'insurance_quote'

RSpec.describe InsuranceQuote do
  context 'with four covers' do
    let(:request) do
      {
        "covers": {
          "tires": 10,
          "windows": 50,
          "engine": 20,
          "contents": 30
        }
      }
    end

    it 'calculates a quote for insurer a' do
      result = InsuranceQuote.create(request)
      expect(result[:insurer_a]).to eq(8)
    end

    it 'calculates a quote for insurer b' do
      result = InsuranceQuote.create(request)
      expect(result[:insurer_b]).to eq(7.5)
    end
    
    it 'calculates a quote for insurer c' do
      result = InsuranceQuote.create(request)
      expect(result[:insurer_c]).to eq(6)
    end
  end

  context 'with only one matching cover for insurer a' do
    let(:request) do
      {
        "covers": {
          "tires": 10,
          "windows": 5,
          "engine": 20,
          "contents": 30
        }
      }
    end

    it 'calculates a quote for insurer a' do
      result = InsuranceQuote.create(request)
      expect(result[:insurer_a]).to eq(6)
    end
  end
end

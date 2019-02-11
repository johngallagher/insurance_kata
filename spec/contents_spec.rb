
class InsuranceQuote
  TWO_MATCH_RATE = 0.1
  ONE_MATCH_RATES = {
    0 => 0.2,
    1 => 0.25,
    2 => 0.3
  }

  def initialize request
    @request = request
  end

  def create
    { 
      insurer_a: quote_for(:insurer_a) * (match_rate_for :insurer_a),
      insurer_b: quote_for(:insurer_b) * (match_rate_for :insurer_b),
      insurer_c: quote_for(:insurer_c) * (match_rate_for :insurer_c)
    }
  end

  def match_rate_for insurer
    matching_covers_for(insurer).one? ? one_match_rate_for(insurer) : TWO_MATCH_RATE
  end

  def self.create request
    new(request).create
  end

  def one_match_rate_for insurer
    ONE_MATCH_RATES.fetch(index_of_first_match_for(insurer))
  end

  def index_of_first_match_for insurer
    top_three.keys.index(matching_covers_for(insurer).first)
  end

  def matching_covers_for insurer
    rates_for(insurer).split("+").map(&:to_sym) & top_three.keys 
  end

  def quote_for insurer
    top_three.values_at(*rates_for(insurer).split("+").map(&:to_sym)).compact.inject(&:+)
  end

  def rates_for insurer
    configuration[:insurer_rates][insurer]
  end

  def top_three
    @request.fetch(:covers).sort_by { |_, value| value }.reverse[0..2].yield_self { |items| Hash[items] }
  end

  def configuration
    {
      "insurer_rates": {
        "insurer_a": "windows+contents",
        "insurer_b": "tires+contents",
        "insurer_c": "doors+engine"
      }
    }
  end
end

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

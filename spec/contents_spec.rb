
class Contents
  def self.calculate request
    { 
      insurer_a: quote_for_insurer_a(request) * 0.1,
      insurer_b: quote_for_insurer_b(request) * 0.25
    }
  end

  def self.quote_for_insurer_a(request)
    top_three(request).values_at(*insurer_a_rates.split("+").map(&:to_sym)).compact.inject(&:+)
  end

  def self.quote_for_insurer_b(request)
    top_three(request).values_at(*insurer_b_rates.split("+").map(&:to_sym)).compact.inject(&:+)
  end

  def self.insurer_a_rates
    configuration[:insurer_rates][:insurer_a]
  end

  def self.insurer_b_rates
    configuration[:insurer_rates][:insurer_b]
  end

  def self.top_three(request)
    request.fetch(:covers).sort_by { |_, value| value }.reverse[0..2].yield_self { |items| Hash[items] }
  end

  def self.configuration
    {
      "insurer_rates": {
        "insurer_a": "windows+contents",
        "insurer_b": "tires+contents",
        "insurer_c": "doors+engine"
      }
    }
  end
end

RSpec.describe Contents do
  context 'with four covers and one insurer' do
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
      result = Contents.calculate(request)
      expect(result[:insurer_a]).to eq(8)
    end

    it 'calculates a quote for insurer b' do
      result = Contents.calculate(request)
      expect(result[:insurer_b]).to eq(7.5)
    end
  end
end

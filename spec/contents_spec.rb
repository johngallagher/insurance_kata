
class Contents
  def self.calculate request
    { insurer_a: quote(request) * 0.1 }
  end

  def self.quote(request)
    top_three(request).values_at(*insurer_a_rates.split("+").map(&:to_sym)).inject(&:+)
  end

  def self.insurer_a_rates
    configuration[:insurer_rates][:insurer_a]
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
      expect(result).to eq(insurer_a: 8)
    end
  end
end

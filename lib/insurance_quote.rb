require 'insurer'

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

  def self.create request
    new(request).create
  end

  def create
    insurers.inject({}) do |quotes, insurer|
      quotes.merge(insurer.final_quote(top_three))
    end
  end

  def insurers
    Insurer.from_configuration(configuration)
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



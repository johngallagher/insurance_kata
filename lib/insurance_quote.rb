class Insurer
  TWO_MATCH_RATE = 0.1
  ONE_MATCH_RATES = {
    0 => 0.2,
    1 => 0.25,
    2 => 0.3
  }
  attr_reader :name

  def initialize name, rates:
    @name = name
    @rates = rates.split("+").map(&:to_sym)
  end

  def final_quote(top_three)
    {
      name => quote(top_three) * match_rate_for(top_three)
    }
  end

  def quote(top_three)
    top_three.values_at(*@rates).compact.inject(&:+)
  end

  def match_rate_for top_three
    matching_covers_for(top_three).one? ? one_match_rate_for(top_three) : TWO_MATCH_RATE
  end

  def one_match_rate_for top_three
    ONE_MATCH_RATES.fetch(index_of_first_match_for(top_three))
  end

  def index_of_first_match_for top_three
    top_three.keys.index(matching_covers_for(top_three).first)
  end

  def matching_covers_for top_three
    @rates & top_three.keys 
  end
end

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
    [
      Insurer.new(:insurer_a, rates: "windows+contents"),
      Insurer.new(:insurer_b, rates: "tires+contents"),
      Insurer.new(:insurer_c, rates: "doors+engine")
    ]
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



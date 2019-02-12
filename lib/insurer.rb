class Insurer
  TWO_MATCH_RATE = 0.1
  ONE_MATCH_RATES = [0.2, 0.25, 0.3]
  attr_reader :name

  def initialize name, rates:
    @name = name
    @rates = rates
  end

  def self.from_configuration configuration
    configuration[:insurer_rates].map do |name, rates|
      Insurer.new name, rates: rates.split("+").map(&:to_sym)
    end
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
    ONE_MATCH_RATES[index_of_first_match_for(top_three)]
  end

  def index_of_first_match_for top_three
    top_three.keys.index(matching_covers_for(top_three).first)
  end

  def matching_covers_for top_three
    @rates & top_three.keys 
  end
end


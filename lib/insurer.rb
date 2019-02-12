class Insurer
  TWO_MATCH_RATE = 0.1
  ONE_MATCH_RATES = [0.2, 0.25, 0.3]
  attr_reader :name

  def initialize name, covers:
    @name = name
    @covers = covers
  end

  def self.from_configuration configuration
    configuration[:insurer_rates].map do |name, covers|
      Insurer.new name, covers: covers.split("+").map(&:to_sym)
    end
  end

  def to_quote(top_three)
    {
      name => total_cover(top_three) * match_rate_for(top_three)
    }
  end

  def total_cover(top_three)
    top_three.yield_self(&cover_amounts).compact.inject(&:+)
  end

  def cover_amounts
    ->(cover_with_amounts) { cover_with_amounts.values_at(*@covers) }
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
    @covers & top_three.keys
  end
end

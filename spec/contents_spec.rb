
class Contents
  def self.calculate request
    request.fetch(:covers).sort_by { |key, value| value }.reverse[0..2].map(&:first)
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
    it 'selects the three biggest covers' do
      result = Contents.calculate(request)
      expect(result).to eq([:windows, :contents, :engine])
    end
  end
end

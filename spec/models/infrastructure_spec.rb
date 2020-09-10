require "rails_helper"

RSpec.describe Infrastructure, type: :model do
  describe "#services" do
    it "returns an array of services" do
      result = described_class.new(services: [{"name" => "test-service"}]).services
      expect(result).to eql([{"name" => "test-service"}])
    end

    context "when this infrastructure has services" do
      it "returns an empty array" do
        result = described_class.new.services
        expect(result).to eql([])
      end
    end
  end
end

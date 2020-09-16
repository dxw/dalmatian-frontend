require "rails_helper"

RSpec.describe Result, type: :model do
  describe "#success?" do
    context "when it has been marked as success" do
      it "returns true" do
        result = described_class.new(true).success?
        expect(result).to eq(true)
      end
    end

    context "when it has been marked as failed" do
      it "returns false" do
        result = described_class.new(false).success?
        expect(result).to eq(false)
      end
    end
  end

  describe "#failure?" do
    context "when it has been marked as failed" do
      it "returns true" do
        result = described_class.new(false).failure?
        expect(result).to eq(true)
      end
    end

    context "when it has been marked as success" do
      it "returns false" do
        result = described_class.new(true).failure?
        expect(result).to eq(false)
      end
    end
  end
end

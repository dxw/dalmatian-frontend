require "rails_helper"

RSpec.describe EnvFile, type: :model do
  describe ".valid?" do
    it "returns true for .env files with the expected = separated values" do
      good_file = File.open("#{Rails.root}/spec/fixtures/env_files/test.env")
      result = described_class.valid?(tempfile: good_file)
      expect(result).to eq(true)
    end

    context "when the lines don't parse as valid ENV pairs" do
      it "returns false" do
        bad_file = File.open("#{Rails.root}/spec/fixtures/env_files/bad_structure.env")
        result = described_class.valid?(tempfile: bad_file)
        expect(result).to eq(false)
      end
    end

    context "when the file format is not .env" do
      it "returns false" do
        bad_file = File.open("#{Rails.root}/spec/fixtures/env_files/bad_file_type.jpg")
        result = described_class.valid?(tempfile: bad_file)
        expect(result).to eq(false)
      end
    end

    context "when the values are wrapped in quotes" do
      it "returns false" do
        bad_file = File.open("#{Rails.root}/spec/fixtures/env_files/with_quotes.env")
        result = described_class.valid?(tempfile: bad_file)
        expect(result).to eq(false)
      end
    end

    context "when the contents include special characters" do
      it "returns true" do
        bad_file = File.open("#{Rails.root}/spec/fixtures/env_files/with_special_characters.env")
        result = described_class.valid?(tempfile: bad_file)
        expect(result).to eq(true)
      end
    end
  end
end

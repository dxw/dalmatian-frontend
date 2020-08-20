require "rails_helper"

RSpec.describe FindDalmatianConfiguration do
  describe "#infrastructures" do
    it "returns the names of each infrastructure" do
      fake_config = File.read("spec/fixtures/dalmatian-config/dalmatian.yml")
      allow(File).to receive(:read).and_return(fake_config)

      result = described_class.new.infrastructures

      expect(result).to match(
        [
          "new-dedicated-cluster",
          "shared-new-cluster",
          "existing-shared-cluster-staging",
          "existing-shared-cluster-production"
        ]
      )
    end
  end
end

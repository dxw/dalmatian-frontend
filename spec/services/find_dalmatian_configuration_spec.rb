require "rails_helper"

RSpec.describe FindDalmatianConfiguration do
  describe "#call" do
    it "returns a hash of the contents of dalmatian.yml" do
      fake_config = File.read("spec/fixtures/dalmatian-config/dalmatian.yml")
      allow(File).to receive(:read).and_return(fake_config)

      result = described_class.new.call

      expect(result.keys).to match(
        [
          "parameter-store-path-prefix",
          "account-bootstrap",
          "ci",
          "infrastructure-defaults",
          "infrastructures"
        ]
      )
    end
  end
end

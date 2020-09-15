require "rails_helper"

RSpec.describe EnvironmentVariable, type: :model do
  describe "#full_aws_name" do
    it "returns an array of all the environment names" do
      environment_variable = described_class.new(
        name: "secret_name",
        service_name: "test-service",
        environment_name: "staging"
      )

      result = environment_variable.full_aws_name

      expect(result).to eql("test-service/staging/secret_name")
    end
  end
end

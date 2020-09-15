require "rails_helper"

RSpec.describe DeleteEnvironmentVariable do
  let(:infrastructure) do
    Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      services: [{"name" => "test-service"}],
      environments: {"staging" => []}
    )
  end

  let(:aws_ssm_client) { stub_aws_ssm_client(account_id: infrastructure.account_id) }

  describe "#call" do
    it "sends a delete request to AWS" do
      environment_variable = EnvironmentVariable.new(
        name: "FOO",
        service_name: "BAR",
        environment_name: "BAZ"
      )

      expect(aws_ssm_client).to receive(:delete_parameter)
        .with(name: "test-app/BAR/BAZ/FOO")

      result = described_class.new(infrastructure: infrastructure)
        .call(environment_variable: environment_variable)

      expect(result.success?).to eq(true)
    end

    context "when AWS errors with parameter not found" do
      it "returns a failed result object" do
        environment_variable = EnvironmentVariable.new(
          name: "FOO",
          service_name: "BAR",
          environment_name: "BAZ"
        )

        allow(aws_ssm_client).to receive(:delete_parameter)
          .with(name: "test-app/BAR/BAZ/FOO")
          .and_raise(Aws::SSM::Errors::ParameterNotFound.new(anything, "Not found"))

        result = described_class.new(infrastructure: infrastructure)
          .call(environment_variable: environment_variable)

        expect(result.success?).to eq(false)
        expect(result.error_message).to eq("Parameter was not found")
      end
    end
  end
end

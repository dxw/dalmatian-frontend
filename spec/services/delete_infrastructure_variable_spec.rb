require "rails_helper"

RSpec.describe DeleteInfrastructureVariable do
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
      infrastructure_variable = InfrastructureVariable.new(
        name: "FOO",
        environment_name: "BAZ"
      )

      expect(aws_ssm_client).to receive(:delete_parameter)
        .with(name: "/dalmatian-variables/infrastructures/#{infrastructure.identifier}/#{infrastructure_variable.environment_name}/#{infrastructure_variable.name}")

      result = described_class.new(infrastructure: infrastructure)
        .call(infrastructure_variable: infrastructure_variable)

      expect(result.success?).to eq(true)
    end

    context "when AWS errors with parameter not found" do
      it "returns a failed result object" do
        infrastructure_variable = InfrastructureVariable.new(
          name: "FOO",
          environment_name: "BAZ"
        )

        allow(aws_ssm_client).to receive(:delete_parameter)
          .with(name: "/dalmatian-variables/infrastructures/#{infrastructure.identifier}/#{infrastructure_variable.environment_name}/#{infrastructure_variable.name}")
          .and_raise(Aws::SSM::Errors::ParameterNotFound.new(anything, "Not found"))

        result = described_class.new(infrastructure: infrastructure)
          .call(infrastructure_variable: infrastructure_variable)

        expect(result.success?).to eq(false)
        expect(result.error_message).to eq("Parameter was not found")
      end
    end
  end
end

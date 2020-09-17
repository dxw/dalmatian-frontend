require "rails_helper"

RSpec.describe FindInfrastructureVariables do
  describe "#call" do
    it "returns a hash of infrastructure variables grouped by environment" do
      infrastructure = Infrastructure.new(
        identifier: "test",
        account_id: "345",
        environments: {"staging" => []}
      )

      fake_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAR")
      fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
        parameters: [fake_environment_variable]
      )

      stub_call_to_aws_for_environment_variables(
        account_id: infrastructure.account_id,
        request_path: "/dalmatian-variables/infrastructures/test/staging/",
        environment_variables: fake_environment_variables
      )

      result = described_class.new(infrastructure: infrastructure).call

      expect(result).to eq({
        "staging" => [fake_environment_variable]
      })
    end

    context "when there are multiple environments" do
      it "returns a hash of infrastructure variables grouped by environment" do
        infrastructure = Infrastructure.new(
          identifier: "test",
          account_id: "345",
          environments: {
            "staging" => [],
            "production" => []
          }
        )

        fake_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAR")
        fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
          parameters: [fake_environment_variable]
        )

        aws_ssm_client = stub_aws_ssm_client(account_id: infrastructure.account_id)
        stub_call_to_aws_for_environment_variables(
          account_id: infrastructure.account_id,
          aws_ssm_client_double: aws_ssm_client,
          request_path: "/dalmatian-variables/infrastructures/test/staging/",
          environment_variables: fake_environment_variables
        )

        stub_call_to_aws_for_environment_variables(
          account_id: infrastructure.account_id,
          aws_ssm_client_double: aws_ssm_client,
          request_path: "/dalmatian-variables/infrastructures/test/production/",
          environment_variables: fake_environment_variables
        )

        result = described_class.new(infrastructure: infrastructure).call

        expect(result).to eq({
          "staging" => [fake_environment_variable],
          "production" => [fake_environment_variable]
        })
      end
    end
  end
end

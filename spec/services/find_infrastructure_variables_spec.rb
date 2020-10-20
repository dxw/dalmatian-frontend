require "rails_helper"

RSpec.describe FindInfrastructureVariables do
  describe "#call" do
    let(:aws_ssm_client) do
      stub_aws_ssm_client(
        aws_sts_client: stub_main_aws_sts_client,
        account_id: ENV["DALMATIAN_AWS_ACCOUNT_ID"]
      )
    end

    it "returns a hash of infrastructure variables grouped by environment" do
      infrastructure = Infrastructure.new(
        identifier: "test",
        account_id: "345",
        environments: {"staging" => []}
      )

      fake_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAR")
      fake_environment_variables = [Aws::SSM::Types::GetParametersByPathResult.new(
        parameters: [fake_environment_variable]
      )]

      stub_call_to_aws_for_infrastructure_variables(
        service_name: "test",
        environment_name: "staging",
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
        fake_environment_variables = [Aws::SSM::Types::GetParametersByPathResult.new(
          parameters: [fake_environment_variable]
        )]

        stub_call_to_aws_for_infrastructure_variables(
          aws_ssm_client: aws_ssm_client,
          service_name: "test",
          environment_name: "staging",
          environment_variables: fake_environment_variables
        )

        stub_call_to_aws_for_infrastructure_variables(
          aws_ssm_client: aws_ssm_client,
          service_name: "test",
          environment_name: "production",
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

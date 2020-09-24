require "rails_helper"

RSpec.describe FindEnvironmentVariables do
  describe "#call" do
    it "returns a hash of environment variables grouped by service and environment" do
      infrastructure = Infrastructure.new(
        identifier: "test",
        account_id: "345",
        services: [{"name" => "test-service"}],
        environments: {"staging" => []}
      )

      fake_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAR")
      fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
        parameters: [fake_environment_variable]
      )

      stub_call_to_aws_for_environment_variables(
        account_id: infrastructure.account_id,
        infrastructure_name: infrastructure.identifier,
        service_name: "test-service",
        environment_name: "staging",
        environment_variables: fake_environment_variables
      )

      result = described_class.new(infrastructure: infrastructure).call

      expect(result).to eq({
        "test-service" => {
          "staging" => [fake_environment_variable]
        }
      })
    end

    context "when there are multiple services and environments" do
      it "returns a hash of environment variables grouped by service and environment" do
        infrastructure = Infrastructure.new(
          identifier: "test",
          account_id: "345",
          services: [
            {"name" => "first-service"},
            {"name" => "second-service"}
          ],
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
          aws_ssm_client_double: aws_ssm_client,
          account_id: infrastructure.account_id,
          infrastructure_name: infrastructure.identifier,
          service_name: "first-service",
          environment_name: "staging",
          environment_variables: fake_environment_variables
        )

        stub_call_to_aws_for_environment_variables(
          aws_ssm_client_double: aws_ssm_client,
          account_id: infrastructure.account_id,
          infrastructure_name: infrastructure.identifier,
          service_name: "first-service",
          environment_name: "production",
          environment_variables: fake_environment_variables
        )

        stub_call_to_aws_for_environment_variables(
          aws_ssm_client_double: aws_ssm_client,
          account_id: infrastructure.account_id,
          infrastructure_name: infrastructure.identifier,
          service_name: "second-service",
          environment_name: "staging",
          environment_variables: fake_environment_variables
        )

        stub_call_to_aws_for_environment_variables(
          aws_ssm_client_double: aws_ssm_client,
          account_id: infrastructure.account_id,
          infrastructure_name: infrastructure.identifier,
          service_name: "second-service",
          environment_name: "production",
          environment_variables: fake_environment_variables
        )

        result = described_class.new(infrastructure: infrastructure).call

        expect(result).to eq({
          "first-service" => {
            "staging" => [fake_environment_variable],
            "production" => [fake_environment_variable]
          },
          "second-service" => {
            "staging" => [fake_environment_variable],
            "production" => [fake_environment_variable]
          }
        })
      end
    end
  end
end

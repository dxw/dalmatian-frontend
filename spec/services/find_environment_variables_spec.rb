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

      fake_environment_variable = Aws::SSM::Types::Parameter.new(
        name: "FOO",
        type: "SecureString",
        value: "BAR",
        version: 19,
        selector: nil,
        source_result: nil,
        last_modified_date: Time.new("2020-04-22 14:15:43 +0100"),
        arn: "arn:aws:ssm:eu-west-2:345:parameter/test-app/test-service/staging/FOO",
        data_type: "text"
      )

      fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
        parameters: [fake_environment_variable]
      )

      stub_call_to_aws_for_environment_variables(
        account_id: infrastructure.account_id,
        request_path: "/test/test-service/staging/",
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

        fake_environment_variable = Aws::SSM::Types::Parameter.new(
          name: "FOO",
          type: "SecureString",
          value: "BAR",
          version: 19,
          selector: nil,
          source_result: nil,
          last_modified_date: Time.new("2020-04-22 14:15:43 +0100"),
          arn: "arn:aws:ssm:eu-west-2:345:parameter/test-app/test-service/staging/FOO",
          data_type: "text"
        )

        fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
          parameters: [fake_environment_variable]
        )

        aws_client_double = instance_double(Aws::SSM::Client)
        stub_call_to_aws_for_environment_variables(
          account_id: infrastructure.account_id,
          aws_client_double: aws_client_double,
          request_path: "/test/first-service/staging/",
          environment_variables: fake_environment_variables
        )

        stub_call_to_aws_for_environment_variables(
          account_id: infrastructure.account_id,
          aws_client_double: aws_client_double,
          request_path: "/test/first-service/production/",
          environment_variables: fake_environment_variables
        )

        stub_call_to_aws_for_environment_variables(
          account_id: infrastructure.account_id,
          aws_client_double: aws_client_double,
          request_path: "/test/second-service/staging/",
          environment_variables: fake_environment_variables
        )

        stub_call_to_aws_for_environment_variables(
          account_id: infrastructure.account_id,
          aws_client_double: aws_client_double,
          request_path: "/test/second-service/production/",
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

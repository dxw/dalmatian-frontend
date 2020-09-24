require "rails_helper"

RSpec.describe GetAwsParameter do
  include AwsClientWrapper

  describe "#call" do
    let(:aws_ssm_client) { stub_aws_ssm_client(account_id: "345") }

    it "returns a hash of variables grouped by environment" do
      infrastructure = Infrastructure.new(account_id: "345", identifier: "fee")

      fake_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAR")
      fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
        parameters: [fake_environment_variable]
      )

      stub_call_to_aws_for_environment_variables(
        aws_ssm_client: aws_ssm_client,
        account_id: infrastructure.account_id,
        infrastructure_name: infrastructure.identifier,
        service_name: "bar",
        environment_name: "baz",
        environment_variables: fake_environment_variables
      )

      expected_request_path = "/fee/bar/baz/"

      result = described_class.new(aws_ssm_client: aws_ssm_client, path: expected_request_path).call

      expect(result).to eq([fake_environment_variable])
    end
  end
end

require "rails_helper"

RSpec.describe GetAwsParameter do
  include AwsClientWrapper

  describe "#call" do
    let(:aws_ssm_client) { stub_aws_ssm_client(account_id: "345") }
    let(:infrastructure) { Infrastructure.new(account_id: "345", identifier: "fee") }

    it "returns a hash of variables grouped by environment" do
      fake_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAR")
      fake_environment_variables = [Aws::SSM::Types::GetParametersByPathResult.new(
        parameters: [fake_environment_variable]
      )]

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

    context "when AWS returns more than 10 results" do
      it "returns more than 10" do
        fake_environment_variables = [
          Aws::SSM::Types::GetParametersByPathResult.new(
            parameters: [
              create_aws_environment_variable(name: "1", value: "1"),
              create_aws_environment_variable(name: "2", value: "2"),
              create_aws_environment_variable(name: "3", value: "3"),
              create_aws_environment_variable(name: "4", value: "4"),
              create_aws_environment_variable(name: "5", value: "5"),
              create_aws_environment_variable(name: "6", value: "6"),
              create_aws_environment_variable(name: "7", value: "7"),
              create_aws_environment_variable(name: "8", value: "8"),
              create_aws_environment_variable(name: "9", value: "9"),
              create_aws_environment_variable(name: "10", value: "10")
            ]
          ),
          Aws::SSM::Types::GetParametersByPathResult.new(
            parameters: [
              create_aws_environment_variable(name: "11", value: "11")
            ]
          )
        ]

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

        expect(result.count).to eq(11)
        expect(result.last.name).to eql("11")
      end
    end
  end
end

require "rails_helper"

RSpec.describe GetAwsParameter do
  describe "#call" do
    it "returns a hash of infrastructure variables grouped by environment" do
      infrastructure = Infrastructure.new(account_id: "345")
      expected_request_path = "/foo/bar/baz"

      fake_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAR")
      fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
        parameters: [fake_environment_variable]
      )

      stub_call_to_aws_for_environment_variables(
        account_id: infrastructure.account_id,
        request_path: expected_request_path,
        environment_variables: fake_environment_variables
      )

      result = described_class.new(infrastructure: infrastructure, path: expected_request_path).call

      expect(result).to eq([fake_environment_variable])
    end
  end
end

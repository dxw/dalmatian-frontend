require "rails_helper"

RSpec.describe PutAwsParameter do
  describe "#call" do
    it "asks AWS to update the variable" do
      infrastructure = Infrastructure.new(account_id: "345")
      expected_request_path = "/foo/bar/baz/FOO"
      expected_key_id = "alias/foo-bar-baz-ssm"

      stub_call_to_aws_to_update_environment_variables(
        account_id: infrastructure.account_id,
        infrastructure_identifier: "foo",
        service_name: "bar",
        environment_name: "baz",
        variable_name: "FOO",
        variable_value: "BAR"
      )

      result = described_class.new(
        infrastructure: infrastructure
      ).call(
        path: expected_request_path,
        key_id: expected_key_id,
        value: "BAR"
      )

      expect(result).to be_kind_of(Aws::SSM::Types::PutParameterResult)
    end
  end
end

require "rails_helper"

RSpec.describe DeleteAwsParameter do
  describe "#call" do
    it "returns an object with the new parameter version number" do
      infrastructure = Infrastructure.new(account_id: "345")

      stub_call_to_aws_to_delete_environment_variable(
        account_id: infrastructure.account_id,
        request_path: "/dalmatian-variables/infrastructures/test-app/staging",
        name: "EXISTING_VARIABLE_NAME"
      )

      expected_request_path = "/dalmatian-variables/infrastructures/test-app/staging/EXISTING_VARIABLE_NAME"

      result = described_class.new(infrastructure: infrastructure)
        .call(path: expected_request_path)

      expect(result).to be_kind_of(Result)
      expect(result.success?).to eq(true)
    end
  end
end

require "rails_helper"

RSpec.describe DeleteAwsParameter do
  describe "#call" do
    let(:aws_ssm_client) { stub_aws_ssm_client(account_id: AwsApiHelpers::CORE_AWS_ACCOUNT_ID) }

    it "returns an object with the new parameter version number" do
      infrastructure = Infrastructure.new(account_id: "345")

      stub_call_to_aws_to_delete_infrastructure_variable(
        aws_ssm_client: aws_ssm_client,
        account_id: infrastructure.account_id,
        service_name: "test-app",
        environment_name: "staging",
        variable_name: "EXISTING_VARIABLE_NAME"
      )

      expected_request_path = "/dalmatian-variables/infrastructures/test-app/staging/EXISTING_VARIABLE_NAME"

      result = described_class.new(aws_ssm_client: aws_ssm_client, infrastructure: infrastructure)
        .call(path: expected_request_path)

      expect(result).to be_kind_of(Result)
      expect(result.success?).to eq(true)
    end
  end
end

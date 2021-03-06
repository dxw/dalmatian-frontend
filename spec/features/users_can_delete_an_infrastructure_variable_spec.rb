feature "Users can delete infrastructure variables" do
  let(:infrastructure) do
    Infrastructure.create(
      identifier: "test-app",
      account_id: "9923123",
      services: [{"name" => "test-service"}],
      environments: {"staging" => []}
    )
  end
  let(:aws_ssm_client) { stub_aws_ssm_client(aws_sts_client: stub_main_aws_sts_client, account_id: ENV["DALMATIAN_AWS_ACCOUNT_ID"]) }

  scenario "delete a single variable", js: true do
    existing_environment_variable = create_aws_environment_variable(name: "EXISTING_VARIABLE_NAME", value: "EXISTING_VARIABLE_VALUE")
    existing_environment_variables = [Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [existing_environment_variable]
    )]

    stub_call_to_aws_for_infrastructure_variables(
      aws_ssm_client: aws_ssm_client,
      service_name: "test-app",
      environment_name: "staging",
      environment_variables: existing_environment_variables
    )

    stub_call_to_aws_to_delete_infrastructure_variable(
      aws_ssm_client: aws_ssm_client,
      account_id: infrastructure.account_id,
      service_name: "test-app",
      environment_name: "staging",
      variable_name: "EXISTING_VARIABLE_NAME"
    )

    visit infrastructure_variables_path(infrastructure)

    stub_call_to_aws_for_infrastructure_variables(
      aws_ssm_client: aws_ssm_client,
      service_name: "test-app",
      environment_name: "staging",
      environment_variables: [Aws::SSM::Types::GetParametersByPathResult.new(parameters: [])]
    )

    click_on(I18n.t("button.delete"))

    confirm = page.driver.browser.switch_to.alert
    confirm.accept

    expect(page).not_to have_content("EXISTING_VARIABLE_VALUE")
    expect(page).to have_content("EXISTING_VARIABLE_NAME has been successfully deleted")
  end
end

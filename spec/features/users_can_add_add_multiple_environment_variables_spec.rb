feature "Users can add new environment variables" do
  let(:infrastructure) do
    Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      services: [{"name" => "test-service"}],
      environments: {"staging" => []}
    )
  end
  let(:aws_ssm_client) { stub_aws_ssm_client(account_id: infrastructure.account_id) }

  scenario "adds multiple new variables at once using a file" do
    existing_environment_variable = create_aws_environment_variable(name: "EXISTING_VARIABLE_NAME", value: "EXISTING_VARIABLE_VALUE")
    unchanged_environment_variable = create_aws_environment_variable(name: "UNCHANGED_VARIABLE", value: "UNCHANGED_VARIABLE_VALUE")
    existing_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [existing_environment_variable, unchanged_environment_variable]
    )

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_name: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      environment_variables: existing_environment_variables
    )

    visit infrastructure_path(infrastructure)
    click_on(I18n.t("tab.environment_variables"))
    click_on(I18n.t("button.upload_env_file"))

    page.attach_file("#{Rails.root}/spec/fixtures/env_files/test.env")

    click_on(I18n.t("button.continue"))

    expect(page).to have_content(I18n.t("page_title.env_files.confirm"))

    # First pair
    expect(page).to have_content("EXISTING_VARIABLE")
    expect(page).to have_content("NEW_VALUE_FOR_EXISTING")

    # Second pair
    expect(page).to have_content("NEW_VARIABLE")
    expect(page).to have_content("NEW_VALUE")

    stub_call_to_aws_to_update_environment_variables(
      aws_ssm_client: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_identifier: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      variable_name: "EXISTING_VARIABLE",
      variable_value: "NEW_VALUE_FOR_EXISTING"
    )

    stub_call_to_aws_to_update_environment_variables(
      aws_ssm_client: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_identifier: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      variable_name: "NEW_VARIABLE",
      variable_value: "NEW_VALUE"
    )

    existing_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [
        create_aws_environment_variable(name: "UNCHANGED_VARIABLE", value: "UNCHANGED_VARIABLE_VALUE"),
        create_aws_environment_variable(name: "EXISTING_VARIABLE", value: "NEW_VALUE_FOR_EXISTING"),
        create_aws_environment_variable(name: "NEW_VARIABLE", value: "NEW_VALUE")
      ]
    )

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_name: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      environment_variables: existing_environment_variables
    )

    click_on(I18n.t("button.apply"))

    # First pair
    expect(page).to have_content("EXISTING_VARIABLE")
    expect(page).to have_content("NEW_VALUE_FOR_EXISTING")

    # Second pair
    expect(page).to have_content("NEW_VARIABLE")
    expect(page).to have_content("NEW_VALUE")

    # Third pair
    expect(page).to have_content("UNCHANGED_VARIABLE")
    expect(page).to have_content("UNCHANGED_VARIABLE_VALUE")
  end
end

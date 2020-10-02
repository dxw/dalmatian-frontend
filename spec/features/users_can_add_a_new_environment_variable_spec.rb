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

  scenario "adds a new variable" do
    stub_call_to_aws_for_environment_variables(
      aws_ssm_client: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_name: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      environment_variables: Aws::SSM::Types::GetParametersByPathResult.new(parameters: [])
    )

    visit infrastructure_path(infrastructure)
    click_on(I18n.t("tab.environment_variables"))
    click_on(I18n.t("button.add_or_update_variable"))

    within("h1") do
      expect(page).to have_content(I18n.t("page_title.environment_variable.new"))
    end

    stub_call_to_aws_to_update_environment_variables(
      aws_ssm_client: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_identifier: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      variable_name: "FOO",
      variable_value: "BAAZ"
    )

    updated_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAAZ")
    updated_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [updated_environment_variable]
    )

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_name: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      environment_variables: updated_environment_variables
    )

    fill_in "environment_variable[name]", with: "FOO"
    fill_in "environment_variable[value]", with: "BAAZ"
    click_on I18n.t("button.add_or_update_variable")

    expect(page).to have_content("FOO")
    expect(page).to have_content("BAAZ")
    expect(page).to have_content("This variable was successfully set")
    expect(page).to have_content("To apply this change to the service you will need to execute a new deployment from the builds tab")
  end

  scenario "updates an existing variable" do
    existing_environment_variable = create_aws_environment_variable(name: "EXISTING_VARIABLE_NAME", value: "EXISTING_VARIABLE_VALUE")
    existing_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [existing_environment_variable]
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

    expect(page).to have_content("EXISTING_VARIABLE_NAME")
    expect(page).to have_content("EXISTING_VARIABLE_VALUE")

    click_on(I18n.t("button.add_or_update_variable"))

    within("h1") do
      expect(page).to have_content(I18n.t("page_title.environment_variable.new"))
    end

    stub_call_to_aws_to_update_environment_variables(
      aws_ssm_client: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_identifier: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      variable_name: "EXISTING_VARIABLE_NAME",
      variable_value: "NEW_VALUE"
    )

    updated_environment_variable = create_aws_environment_variable(name: "EXISTING_VARIABLE_NAME", value: "NEW_VALUE")
    updated_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [updated_environment_variable]
    )

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_name: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      environment_variables: updated_environment_variables
    )

    fill_in "environment_variable[name]", with: "EXISTING_VARIABLE_NAME"
    fill_in "environment_variable[value]", with: "NEW_VALUE"
    click_on I18n.t("button.add_or_update_variable")

    expect(page).to have_content("EXISTING_VARIABLE_NAME")
    expect(page).to have_content("NEW_VALUE")
    expect(page).to_not have_content("EXISTING_VARIABLE_VALUE")
  end

  scenario "validates the presence of both values" do
    # Deliberately omit query params for service_name and environment_name
    visit new_infrastructure_environment_variable_path(infrastructure)

    fill_in "environment_variable[name]", with: "" # Deliberately omit a value
    fill_in "environment_variable[value]", with: "" # Deliberately omit a value
    click_on I18n.t("button.add_or_update_variable")

    expect(page).to have_content("Service name can't be blank")
    expect(page).to have_content("Environment name can't be blank")
    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("Value can't be blank")
  end
end

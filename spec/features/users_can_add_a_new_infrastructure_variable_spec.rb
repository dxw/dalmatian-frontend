feature "Users can add new infrastructure variables" do
  scenario "adds a new variable" do
    infrastructure = Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      services: [{"name" => "test-service"}],
      environments: {"staging" => []}
    )

    aws_ssm_client = stub_aws_ssm_client(account_id: infrastructure.account_id)

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      request_path: "/dalmatian-variables/infrastructures/test-app/staging/",
      environment_variables: Aws::SSM::Types::GetParametersByPathResult.new(parameters: [])
    )

    visit infrastructure_path(infrastructure)
    click_on(I18n.t("tab.infrastructure_variables"))
    click_on(I18n.t("button.add_or_update_variable"))

    within("h1") do
      expect(page).to have_content(I18n.t("page_title.infrastructure_variable.new"))
    end

    stub_call_to_aws_to_update_infrastructure_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_identifier: infrastructure.identifier,
      environment_name: "staging",
      variable_name: "FOO",
      variable_value: "BAAZ"
    )

    updated_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAAZ")
    updated_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [updated_environment_variable]
    )

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      request_path: "/dalmatian-variables/infrastructures/test-app/staging/",
      environment_variables: updated_environment_variables
    )

    fill_in "infrastructure_variable[name]", with: "FOO"
    fill_in "infrastructure_variable[value]", with: "BAAZ"
    click_on I18n.t("button.add_or_update_variable")

    expect(page).to have_content("FOO")
    expect(page).to have_content("BAAZ")
  end

  scenario "updates an existing variable" do
    infrastructure = Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      services: [{"name" => "test-service"}],
      environments: {"staging" => []}
    )

    aws_ssm_client = stub_aws_ssm_client(account_id: infrastructure.account_id)

    existing_environment_variable = create_aws_environment_variable(name: "EXISTING_VARIABLE_NAME", value: "EXISTING_VARIABLE_VALUE")
    existing_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [existing_environment_variable]
    )

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      request_path: "/dalmatian-variables/infrastructures/test-app/staging/",
      environment_variables: existing_environment_variables
    )

    visit infrastructure_path(infrastructure)
    click_on(I18n.t("tab.infrastructure_variables"))

    expect(page).to have_content("EXISTING_VARIABLE_NAME")
    expect(page).to have_content("EXISTING_VARIABLE_VALUE")

    click_on(I18n.t("button.add_or_update_variable"))

    within("h1") do
      expect(page).to have_content(I18n.t("page_title.infrastructure_variable.new"))
    end

    stub_call_to_aws_to_update_infrastructure_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_identifier: infrastructure.identifier,
      environment_name: "staging",
      variable_name: "EXISTING_VARIABLE_NAME",
      variable_value: "NEW_VALUE"
    )

    updated_environment_variable = create_aws_environment_variable(name: "EXISTING_VARIABLE_NAME", value: "NEW_VALUE")
    updated_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [updated_environment_variable]
    )

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      request_path: "/dalmatian-variables/infrastructures/test-app/staging/",
      environment_variables: updated_environment_variables
    )

    fill_in "infrastructure_variable[name]", with: "EXISTING_VARIABLE_NAME"
    fill_in "infrastructure_variable[value]", with: "NEW_VALUE"
    click_on I18n.t("button.add_or_update_variable")

    expect(page).to have_content("EXISTING_VARIABLE_NAME")
    expect(page).to have_content("NEW_VALUE")
    expect(page).to_not have_content("EXISTING_VARIABLE_VALUE")
  end
end

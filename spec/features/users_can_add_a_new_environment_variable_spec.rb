feature "Users can add new environment variables" do
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
      request_path: "/test-app/test-service/staging/",
      environment_variables: Aws::SSM::Types::GetParametersByPathResult.new(parameters: [])
    )

    visit infrastructure_path(infrastructure)

    click_on(I18n.t("button.add_or_update_variable"))

    within("h1") do
      expect(page).to have_content(I18n.t("page_title.environment_variable.new"))
    end

    stub_call_to_aws_to_update_environment_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_identifier: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      variable_name: "FOO",
      variable_value: "BAAZ"
    )

    updated_environment_variable = Aws::SSM::Types::Parameter.new(
      name: "FOO",
      type: "SecureString",
      value: "BAAZ",
      version: 19,
      selector: nil,
      source_result: nil,
      last_modified_date: Time.new("2020-04-22 14:15:43 +0100"),
      arn: "arn:aws:ssm:eu-west-2:345:parameter/test-app/test-service/staging/FOO",
      data_type: "text"
    )

    updated_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [updated_environment_variable]
    )

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      request_path: "/test-app/test-service/staging/",
      environment_variables: updated_environment_variables
    )

    fill_in "environment_variable[name]", with: "FOO"
    fill_in "environment_variable[value]", with: "BAAZ"
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

    existing_environment_variable = Aws::SSM::Types::Parameter.new(
      name: "EXISTING_VARIABLE_NAME",
      type: "SecureString",
      value: "EXISTING_VARIABLE_VALUE",
      version: 19,
      selector: nil,
      source_result: nil,
      last_modified_date: Time.new("2020-04-22 14:15:43 +0100"),
      arn: "arn:aws:ssm:eu-west-2:345:parameter/test-app/test-service/staging/FOO",
      data_type: "text"
    )

    existing_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [existing_environment_variable]
    )

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      request_path: "/test-app/test-service/staging/",
      environment_variables: existing_environment_variables
    )

    visit infrastructure_path(infrastructure)

    expect(page).to have_content("EXISTING_VARIABLE_NAME")
    expect(page).to have_content("EXISTING_VARIABLE_VALUE")

    click_on(I18n.t("button.add_or_update_variable"))

    within("h1") do
      expect(page).to have_content(I18n.t("page_title.environment_variable.new"))
    end

    stub_call_to_aws_to_update_environment_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      infrastructure_identifier: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      variable_name: "EXISTING_VARIABLE_NAME",
      variable_value: "NEW_VALUE"
    )

    updated_environment_variable = Aws::SSM::Types::Parameter.new(
      name: "EXISTING_VARIABLE_NAME",
      type: "SecureString",
      value: "NEW_VALUE",
      version: 19,
      selector: nil,
      source_result: nil,
      last_modified_date: Time.new("2020-04-22 14:15:43 +0100"),
      arn: "arn:aws:ssm:eu-west-2:345:parameter/test-app/test-service/staging/FOO",
      data_type: "text"
    )

    updated_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
      parameters: [updated_environment_variable]
    )

    stub_call_to_aws_for_environment_variables(
      aws_ssm_client_double: aws_ssm_client,
      account_id: infrastructure.account_id,
      request_path: "/test-app/test-service/staging/",
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
    infrastructure = Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      services: [{"name" => "test-service"}],
      environments: {"staging" => []}
    )

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

feature "Users can download environment variables" do
  scenario "lists out the keys and values" do
    infrastructure = Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      services: [{"name" => "test-service"}],
      environments: {"staging" => []}
    )

    fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(parameters: [
      create_aws_environment_variable(name: "FOO", value: "BAR"),
      create_aws_environment_variable(name: "DATABASE_URL", value: "BAZ")
    ])

    stub_call_to_aws_for_environment_variables(
      account_id: infrastructure.account_id,
      infrastructure_name: infrastructure.identifier,
      service_name: "test-service",
      environment_name: "staging",
      environment_variables: fake_environment_variables
    )

    visit infrastructure_path(infrastructure)

    click_on(I18n.t("tab.environment_variables"))
    click_on(I18n.t("button.download_environment_variables"))

    expect(page).to have_content("FOO=BAR")
    expect(page).to have_content("DATABASE_URL=BAZ")
  end
end

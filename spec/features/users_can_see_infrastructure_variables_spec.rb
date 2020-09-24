feature "Users can see infrastructure variables" do
  scenario "lists out the keys and values" do
    infrastructure = Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      environments: {"staging" => []}
    )

    fake_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAR")
    fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(parameters: [
      fake_environment_variable
    ])

    stub_call_to_aws_for_infrastructure_variables(
      service_name: "test-app",
      environment_name: "staging",
      environment_variables: fake_environment_variables
    )

    visit infrastructure_path(infrastructure)

    click_on(I18n.t("tab.infrastructure_variables"))

    expect(page).to have_content("Infrastructure variables")
    expect(page).to have_content("staging")
    expect(page).to have_content("FOO")
    expect(page).to have_content("BAR")
    expect(page).to have_content(Time.new("2020-04-22 14:15:43 +0100").to_s)
    expect(page).to have_content("19")
    expect(page).to have_content("text")
  end
end

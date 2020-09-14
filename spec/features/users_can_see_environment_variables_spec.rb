feature "Users can see environment variables" do
  scenario "lists out the keys and values" do
    infrastructure = Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      services: [{"name" => "test-service"}],
      environments: {"staging" => []}
    )

    fake_environment_variable = create_aws_environment_variable(name: "FOO", value: "BAR")
    fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(parameters: [
      fake_environment_variable
    ])

    stub_call_to_aws_for_environment_variables(
      account_id: infrastructure.account_id,
      request_path: "/test-app/test-service/staging/",
      environment_variables: fake_environment_variables
    )

    visit infrastructure_path(infrastructure)

    expect(page).to have_content("Environment variables")
    expect(page).to have_content("test-service")
    expect(page).to have_content("FOO")
    expect(page).to have_content("BAR")
    expect(page).to have_content(Time.new("2020-04-22 14:15:43 +0100").to_s)
    expect(page).to have_content("19")
    expect(page).to have_content("text")
  end
end

feature "Users can see environment variables" do
  scenario "lists out the keys and values" do
    infrastructure = Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      services: [{"name" => "test-service"}],
      environments: {"staging" => []}
    )

    fake_environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(parameters: [
      Aws::SSM::Types::Parameter.new(
        name: "FOO",
        type: "SecureString",
        value: "BAR",
        version: 19,
        selector: nil,
        source_result: nil,
        last_modified_date: Time.new("2020-04-22 14:15:43 +0100"),
        arn: "arn:aws:ssm:eu-west-2:345:parameter/test-app/test-service/staging/FOO",
        data_type: "text"
      )
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

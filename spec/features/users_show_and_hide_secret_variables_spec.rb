feature "Users can show and hide secret variables" do
  let(:infrastructure) do
    Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      services: [{"name" => "test-service"}],
      environments: {"staging" => []}
    )
  end

  context "when the app is configured to HIDE secrets by default" do
    around do |example|
      ClimateControl.modify HIDE_SECRETS_BY_DEFAULT: "true" do
        example.run
      end
    end

    scenario "values are hidden by default" do
      environment_variable = create_aws_environment_variable(name: "FOO", value: "BAAZ")
      environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
        parameters: [environment_variable]
      )

      stub_call_to_aws_for_environment_variables(
        account_id: infrastructure.account_id,
        request_path: "/test-app/test-service/staging/",
        environment_variables: environment_variables
      )

      visit infrastructure_environment_variables_path(infrastructure)

      expect(page).to have_content(I18n.t("obfuscation"))
      expect(page).not_to have_content("BAAZ")
    end

    scenario "values can be shown by clicking", js: true do
      environment_variable = create_aws_environment_variable(name: "FOO", value: "BAAZ")
      environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
        parameters: [environment_variable]
      )

      stub_call_to_aws_for_environment_variables(
        account_id: infrastructure.account_id,
        request_path: "/test-app/test-service/staging/",
        environment_variables: environment_variables
      )

      visit infrastructure_environment_variables_path(infrastructure)

      expect(page).to have_content(I18n.t("obfuscation"))

      expect(page).not_to have_content("Create of update variable")

      find(".secret-cell").click

      expect(page).to have_content("BAAZ")
      expect(page).not_to have_content(I18n.t("obfuscation"))
    end
  end

  context "when the app is configured to SHOW secrets by default" do
    around do |example|
      ClimateControl.modify HIDE_SECRETS_BY_DEFAULT: "false" do
        example.run
      end
    end

    scenario "values are shown by default" do
      environment_variable = create_aws_environment_variable(name: "FOO", value: "BAAZ")
      environment_variables = Aws::SSM::Types::GetParametersByPathResult.new(
        parameters: [environment_variable]
      )

      stub_call_to_aws_for_environment_variables(
        account_id: infrastructure.account_id,
        request_path: "/test-app/test-service/staging/",
        environment_variables: environment_variables
      )

      visit infrastructure_environment_variables_path(infrastructure)

      expect(page).not_to have_content(I18n.t("obfuscation"))
      expect(page).to have_content("BAAZ")
    end
  end
end

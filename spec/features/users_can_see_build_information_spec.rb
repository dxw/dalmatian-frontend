feature "Users can see build information" do
  let(:infrastructure) { Infrastructure.create(identifier: "test-app", account_id: "345") }
  let(:aws_code_build_client) { stub_aws_code_build_client(account_id: infrastructure.account_id) }

  scenario "shows the recent builds" do
    stub_call_to_aws_for_project_builds(
      infrastructure_name: infrastructure.identifier,
      aws_code_build_client: aws_code_build_client
    )

    visit infrastructure_path(infrastructure)

    expect(page).to have_content("test-app")
    click_on(I18n.t("tab.logs"))

    within("table") do
      expect(page).to have_content("Number")
      expect(page).to have_content("Status")
      expect(page).to have_content("Start time")
      expect(page).to have_content("Source")
      expect(page).to have_content("Logs")

      expect(page).to have_content("192")
      expect(page).to have_content("2020-09-28 06:20:37 +0100")
      expect(page).to have_content("FAILED")
      expect(page).to have_content("pr/292")
      expect(page).to have_content("View in AWS")
    end
  end
end

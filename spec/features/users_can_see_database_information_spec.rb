feature "Users can see environment variables" do
  scenario "lists out the keys and values" do
    infrastructure = Infrastructure.create(
      identifier: "test-app",
      account_id: "345",
      services: [{"name" => "test-service"}],
      environments: {"staging" => [], "production" => []},
      rds: [
        {
          "identifier" => "bikeshed",
          "instance_class" => "db.t2.small",
          "engine" => "mysql",
          "engine_version" => "5.7.26",
          "db_name" => "bikeshed"
        }
      ]
    )

    visit infrastructure_path(infrastructure)

    click_on(I18n.t("tab.databases"))

    within(".nav-tabs") do
      expect(page).to have_content("Databases")
    end

    within("dl") do
      expect(page).to have_content("Identifier")
      expect(page).to have_content("bikeshed")

      expect(page).to have_content("Name")
      expect(page).to have_content("db.t2.small")

      expect(page).to have_content("Engine")
      expect(page).to have_content("mysql")

      expect(page).to have_content("Engine version")
      expect(page).to have_content("5.7.26")

      expect(page).to have_content("Instance class")
      expect(page).to have_content("bikeshed")
    end

    within("#connect-steps") do
      expect(page).to have_content(I18n.t("database.connect.step.1").html_safe)
      expect(page).to have_content(I18n.t("database.connect.step.2").html_safe)
      expect(page).to have_content(I18n.t("database.connect.step.3"))
    end

    within("#staging-snippet") do
      expect(page).to have_content("dalmatian rds shell -i test-app -e staging -r bikeshed")
    end

    within("#production-snippet") do
      expect(page).to have_content("dalmatian rds shell -i test-app -e production -r bikeshed")
    end
  end
end

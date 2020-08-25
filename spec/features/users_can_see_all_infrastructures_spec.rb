feature "Users can see all infrastructures" do
  scenario "lists out the names of each infrastructure" do
    stub_creation_of_infrastructure_records

    visit root_path

    expect(page).to have_content(I18n.t("app.name"))
    expect(page).to have_content(I18n.t("page_title.infrastructures"))
    expect(page).to have_content("new-dedicated-cluster")
  end

  scenario "a single infrastructure can be viewed" do
    infrastructure = Infrastructure.create(identifier: "test-app", account_id: "345")

    visit root_path

    within("##{infrastructure.id}") do
      click_on("View")
    end

    expect(page).to have_content("test-app")

    within("code") do
      expect(page).to have_content(infrastructure.id)
    end
  end

  scenario "can pick another infrastructure" do
    infrastructure_1 = Infrastructure.create(identifier: "app-1")
    infrastructure_2 = Infrastructure.create(identifier: "app-2")

    visit infrastructures_path(infrastructure_1)

    within("nav") do
      click_on("Infrastructures")
    end

    within("##{infrastructure_2.id}") do
      click_on("View")
    end

    expect(page).to have_content(infrastructure_2.identifier)
  end

  def stub_creation_of_infrastructure_records
    config = YAML.safe_load(File.read("spec/fixtures/dalmatian-config/dalmatian.yml"))
    dalmatian_configuration_double = instance_double(FindDalmatianConfiguration)
    allow(FindDalmatianConfiguration)
      .to receive(:new)
      .and_return(dalmatian_configuration_double)
    allow(dalmatian_configuration_double)
      .to receive(:call)
      .and_return(config)

    CreateInfrastructureRecords.new.call
  end
end

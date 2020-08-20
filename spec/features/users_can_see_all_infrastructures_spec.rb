feature "Users can see all infrastructures" do
  scenario "lists out the names of each infrastructure" do
    stub_infrastructures_file_load

    visit root_path

    expect(page).to have_content(I18n.t("app.name"))
    expect(page).to have_content(I18n.t("page_title.infrastructures"))
    expect(page).to have_content("test-app")
  end

  def stub_infrastructures_file_load
    config = YAML.safe_load(File.read("spec/fixtures/dalmatian-config/dalmatian.yml"))
    dalmatian_configuration_double = instance_double(FindDalmatianConfiguration)
    allow(FindDalmatianConfiguration)
      .to receive(:new)
      .and_return(dalmatian_configuration_double)
    allow(dalmatian_configuration_double)
      .to receive(:infrastructures)
      .and_return(config["infrastructures"])
  end
end

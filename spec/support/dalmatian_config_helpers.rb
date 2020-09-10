module DalmatianConfigHelpers
  def stub_dalmatian_config(file_path: "spec/fixtures/dalmatian-config/dalmatian.yml")
    config = YAML.safe_load(File.read(file_path))
    dalmatian_configuration_double = instance_double(FindDalmatianConfiguration)
    allow(FindDalmatianConfiguration)
      .to receive(:new)
      .and_return(dalmatian_configuration_double)
    allow(dalmatian_configuration_double)
      .to receive(:call)
      .and_return(config)
  end

  def stub_creation_of_infrastructure_records
    stub_dalmatian_config(file_path: "spec/fixtures/dalmatian-config/dalmatian.yml")
    CreateInfrastructureRecords.new.call
  end
end

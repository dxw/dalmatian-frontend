class CreateInfrastructureRecords
  def call
    config = FindDalmatianConfiguration.new.call

    config["infrastructures"].keys.map do |infrastructure_key|
      fields = config["infrastructures"][infrastructure_key]
      fields["identifier"] = infrastructure_key

      Infrastructure.create(fields)
    end
  end
end

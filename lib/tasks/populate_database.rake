desc "Populates MongoDB with the contents of the source of truth: tmp/dalmatian.yml"
task :populate_database, [:entity, :type] => [:environment] do |_task, _args|
  Infrastructure.destroy_all
  CreateInfrastructureRecords.new.call
end

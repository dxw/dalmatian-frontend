class EnvironmentVariable
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name, :value, :service_name, :environment_name

  validates :name, :value, :service_name, :environment_name, presence: true

  def full_aws_name
    "#{service_name}/#{environment_name}/#{name}"
  end
end

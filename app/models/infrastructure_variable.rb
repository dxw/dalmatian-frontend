class InfrastructureVariable
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name, :value, :environment_name

  validates :name, :value, :environment_name, presence: true
end

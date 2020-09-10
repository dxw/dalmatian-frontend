class Infrastructure
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  def services
    super
  rescue NoMethodError
    []
  end

  def environments
    super
  rescue NoMethodError
    {}
  end

  def service_names
    services.map { |service| service["name"] }
  end
end

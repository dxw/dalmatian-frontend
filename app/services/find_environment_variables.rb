class FindEnvironmentVariables
  attr_writer :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call
    results = {}

    infrastructure.services.each do |service|
      service_name = service["name"]
      results[service_name] = {}

      infrastructure.environments.each do |environment_name, _blob|
        results[service_name][environment_name] = fetch_environment_variables(
          service_name: service_name, environment_name: environment_name
        )
      end
    end

    results
  end

  private

  attr_reader :infrastructure

  def aws_role
    ENV["AWS_ROLE"]
  end

  def role_arn
    @role_arn ||= "arn:aws:iam::#{infrastructure.account_id}:role/#{aws_role}"
  end

  def role_session_name
    # ! This is the value in GUI but it looks like it was intended to be 'dalmatian-environment-variables-gui'
    @role_session_name ||= "role_session_name"
  end

  def role_credentials
    @role_credentials ||= Aws::AssumeRoleCredentials.new(
      client: Aws::STS::Client.new,
      role_arn: role_arn,
      role_session_name: role_session_name
    )
  end

  def aws_ssm_client
    @aws_ssm_client ||= Aws::SSM::Client.new(credentials: role_credentials)
  end

  def fetch_environment_variables(service_name:, environment_name:)
    path = "/#{infrastructure.identifier}/#{service_name}/#{environment_name}/"

    parameters = aws_ssm_client.get_parameters_by_path(
      path: path,
      with_decryption: true,
      recursive: false
    ).parameters

    parameters.each { |p| p.name = File.basename(p.name) }
  end
end

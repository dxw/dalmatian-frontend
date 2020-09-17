class GetAwsParameter
  include AwsClientWrapper

  attr_accessor :infrastructure, :path

  def initialize(infrastructure:, path:)
    self.infrastructure = infrastructure
    self.path = path
  end

  def call
    parameters = aws_ssm_client.get_parameters_by_path(
      path: path,
      with_decryption: true,
      recursive: false
    ).parameters

    parameters.each { |p| p.name = File.basename(p.name) }
  end
end

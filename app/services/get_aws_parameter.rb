class GetAwsParameter
  attr_accessor :aws_ssm_client, :path

  def initialize(aws_ssm_client:, path:)
    self.aws_ssm_client = aws_ssm_client
    self.path = path
  end

  def call
    parameters = []
    aws_ssm_client.get_parameters_by_path(
      path: path,
      with_decryption: true,
      recursive: false
    ).each do |response|
      parameters.concat response.parameters
    end
    parameters.each { |p| p.name = File.basename(p.name) }
  end
end

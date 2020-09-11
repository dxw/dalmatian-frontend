module AwsApiHelpers
  def stub_call_to_aws_for_environment_variables(
    account_id:,
    aws_ssm_client_double: nil,
    request_path:,
    environment_variables:
  )
    aws_ssm_client = aws_ssm_client_double || stub_aws_ssm_client(account_id: account_id)

    allow(aws_ssm_client)
      .to receive(:get_parameters_by_path)
      .with(
        path: request_path,
        with_decryption: true,
        recursive: false
      ).and_return(environment_variables).once
  end

  def stub_call_to_aws_to_update_environment_variables(
    aws_ssm_client_double: nil,
    account_id:,
    infrastructure_identifier:,
    service_name:,
    environment_name:,
    variable_name:,
    variable_value:
  )
    aws_ssm_client = aws_ssm_client_double || stub_aws_ssm_client(account_id: account_id)

    path = "/#{infrastructure_identifier}/#{service_name}/#{environment_name}/"
    name_with_path = "#{path}#{variable_name}"
    key_id = "alias/#{infrastructure_identifier}-#{service_name}-#{environment_name}-ssm"

    fake_result = Aws::SSM::Types::PutParameterResult.new(version: 2, tier: "Standard")

    allow(aws_ssm_client)
      .to receive(:put_parameter)
      .with(
        name: name_with_path,
        value: variable_value,
        type: "SecureString",
        key_id: key_id,
        overwrite: true
      ).and_return(fake_result)
  end

  def stub_aws_ssm_client(account_id:)
    credentials = instance_double(Aws::AssumeRoleCredentials)
    allow(Aws::AssumeRoleCredentials).to receive(:new).with(
      client: aws_sts_client,
      role_arn: "arn:aws:iam::#{account_id}:role/#{ENV["AWS_ROLE"]}",
      role_session_name: "role_session_name"
    ).and_return(credentials)

    aws_ssm_client_double = instance_double(Aws::SSM::Client)
    allow(Aws::SSM::Client)
      .to receive(:new)
      .with(credentials: credentials)
      .and_return(aws_ssm_client_double)

    aws_ssm_client_double
  end

  private

  def aws_sts_client
    aws_sts_client = instance_double(Aws::STS::Client)
    allow(Aws::STS::Client).to receive(:new).and_return(aws_sts_client)
    aws_sts_client
  end
end

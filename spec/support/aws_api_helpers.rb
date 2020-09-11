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

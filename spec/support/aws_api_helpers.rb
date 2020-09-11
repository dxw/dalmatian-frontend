module AwsApiHelpers
  def stub_call_to_aws_for_environment_variables(
    account_id:,
    aws_client_double: instance_double(Aws::SSM::Client),
    request_path:,
    environment_variables:
  )
    client = instance_double(Aws::STS::Client)
    allow(Aws::STS::Client).to receive(:new).and_return(client)

    credentials = instance_double(Aws::AssumeRoleCredentials)
    allow(Aws::AssumeRoleCredentials).to receive(:new).with(
      client: client,
      role_arn: "arn:aws:iam::#{account_id}:role/#{ENV["AWS_ROLE"]}",
      role_session_name: "role_session_name"
    ).and_return(credentials)

    allow(Aws::SSM::Client)
      .to receive(:new)
      .with(credentials: credentials)
      .and_return(aws_client_double)

    allow(aws_client_double)
      .to receive(:get_parameters_by_path)
      .with(
        path: request_path,
        with_decryption: true,
        recursive: false
      ).and_return(environment_variables).once
  end
end

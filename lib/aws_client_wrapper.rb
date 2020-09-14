module AwsClientWrapper
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
end

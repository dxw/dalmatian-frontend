module AwsApiHelpers
  CORE_AWS_ACCOUNT_ID = "0011122233344".freeze

  def create_aws_environment_variable(name:, value:)
    Aws::SSM::Types::Parameter.new(
      name: name,
      type: "SecureString",
      value: value,
      version: 19,
      selector: nil,
      source_result: nil,
      last_modified_date: Time.new("2020-04-22 14:15:43 +0100"),
      arn: "arn:aws:ssm:eu-west-2:345:parameter/test-app/test-service/staging/FOO",
      data_type: "text"
    )
  end

  def stub_call_to_aws_for_environment_variables(
    account_id:, infrastructure_name:, service_name:, environment_name:, environment_variables:, aws_ssm_client: nil
  )
    aws_ssm_client ||= stub_aws_ssm_client(account_id: account_id)
    request_path = "/#{infrastructure_name}/#{service_name}/#{environment_name}/"

    allow(aws_ssm_client)
      .to receive(:get_parameters_by_path)
      .with(
        path: request_path,
        with_decryption: true,
        recursive: false
      ).and_return(environment_variables)
  end

  def stub_call_to_aws_for_infrastructure_variables(
    service_name:, environment_name:, environment_variables:, aws_ssm_client: nil
  )
    aws_ssm_client ||= stub_aws_ssm_client(
      aws_sts_client: stub_main_aws_sts_client,
      account_id: CORE_AWS_ACCOUNT_ID
    )
    request_path = "/dalmatian-variables/infrastructures/#{service_name}/#{environment_name}/"

    allow(aws_ssm_client)
      .to receive(:get_parameters_by_path)
      .with(
        path: request_path,
        with_decryption: true,
        recursive: false
      ).and_return(environment_variables)
  end

  def stub_call_to_aws_to_update_environment_variables(
    account_id:, infrastructure_identifier:, service_name:, environment_name:, variable_name:, variable_value:, aws_ssm_client: nil
  )
    aws_ssm_client ||= stub_aws_ssm_client(account_id: account_id)

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

  def stub_call_to_aws_to_update_infrastructure_variables(
    account_id:, infrastructure_identifier:, environment_name:, variable_name:, variable_value:, aws_ssm_client: nil
  )
    aws_ssm_client ||= stub_aws_ssm_client(account_id: account_id)

    path = "/dalmatian-variables/infrastructures/#{infrastructure_identifier}/#{environment_name}/"
    name_with_path = "#{path}#{variable_name}"
    key_id = "alias/dalmatian"

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

  def stub_call_to_aws_to_delete_environment_variable(
    account_id:, infrastructure_name:, service_name:, environment_name:, variable_name:, aws_ssm_client: nil
  )

    aws_ssm_client ||= stub_aws_ssm_client(account_id: account_id)
    full_name = "#{infrastructure_name}/#{service_name}/#{environment_name}/#{variable_name}"

    allow(aws_ssm_client)
      .to receive(:delete_parameter)
      .with(name: full_name)
  end

  def stub_call_to_aws_to_delete_infrastructure_variable(
    account_id:, service_name:, environment_name:, variable_name:, aws_ssm_client: nil
  )

    aws_ssm_client ||= stub_aws_ssm_client(account_id: account_id)
    full_name = "/dalmatian-variables/infrastructures/#{service_name}/#{environment_name}/#{variable_name}"

    allow(aws_ssm_client)
      .to receive(:delete_parameter)
      .with(name: full_name)
  end

  def stub_call_to_aws_for_project_builds(infrastructure_name:, aws_code_build_client:)
    build_id = "dalmatian-ci-test-app:284da6c5-1449-4262-b628-56943d5df4d3"

    builds = Aws::CodeBuild::Types::ListBuildsForProjectOutput.new(ids: [build_id])
    allow(aws_code_build_client)
      .to receive(:list_builds_for_project)
      .with(project_name: "dalmatian-ci-#{infrastructure_name}")
      .and_return(builds)

    detailed_builds = Aws::CodeBuild::Types::BatchGetBuildsOutput.new(
      builds: [
        Aws::CodeBuild::Types::Build.new(
          id: build_id,
          build_number: 192,
          start_time: Time.new(2020, 9, 28, 6, 20, 37),
          build_status: "FAILED",
          source_version: "pr/292",
          logs: Aws::CodeBuild::Types::LogsLocation.new(
            deep_link: "https://console.aws.amazon.com/cloudwatch/home?region=eu-west-2#logEvent:group=/aws/codebuild/dalmatian-ci-test-app;stream=284da6c5-1449-4262-b628-56943d5df4d3"
          )
        )
      ]
    )
    allow(aws_code_build_client)
      .to receive(:batch_get_builds)
      .with(ids: [build_id])
      .and_return(detailed_builds)
  end

  def stub_aws_ssm_client(account_id:, aws_sts_client: stub_aws_sts_client)
    credentials = instance_double(Aws::AssumeRoleCredentials)
    allow(Aws::AssumeRoleCredentials).to receive(:new).with(
      client: aws_sts_client,
      role_arn: "arn:aws:iam::#{account_id}:role/#{ENV["AWS_ROLE"]}",
      role_session_name: "role_session_name"
    ).and_return(credentials)

    aws_ssm_client = instance_double(Aws::SSM::Client)
    allow(Aws::SSM::Client)
      .to receive(:new)
      .with(credentials: credentials)
      .and_return(aws_ssm_client)

    aws_ssm_client
  end

  def stub_main_aws_sts_client
    aws_sts_client = instance_double(Aws::STS::Client)
    allow(Aws::STS::Client).to receive(:new).and_return(aws_sts_client)
    allow(aws_sts_client)
      .to receive_message_chain(:get_caller_identity, :account)
      .and_return(CORE_AWS_ACCOUNT_ID)
    aws_sts_client
  end

  def stub_aws_code_build_client(account_id:, aws_sts_client: stub_aws_sts_client)
    credentials = instance_double(Aws::AssumeRoleCredentials)
    allow(Aws::AssumeRoleCredentials).to receive(:new).with(
      client: aws_sts_client,
      role_arn: "arn:aws:iam::#{account_id}:role/#{ENV["AWS_ROLE"]}",
      role_session_name: "role_session_name"
    ).and_return(credentials)

    aws_ssm_client = instance_double(Aws::CodeBuild::Client)
    allow(Aws::CodeBuild::Client)
      .to receive(:new)
      .with(region: "eu-west-2", credentials: credentials)
      .and_return(aws_ssm_client)

    aws_ssm_client
  end

  private

  def stub_aws_sts_client
    aws_sts_client = instance_double(Aws::STS::Client)
    allow(Aws::STS::Client).to receive(:new).and_return(aws_sts_client)
    aws_sts_client
  end
end

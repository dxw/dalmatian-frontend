module AwsClientWrapper
  class Client
    private

    def aws_role
      ENV["AWS_ROLE"]
    end

    def role_session_name
      # ! This is the value in GUI but it looks like it was intended to be 'dalmatian-environment-variables-gui'
      @role_session_name ||= "role_session_name"
    end

    def role_credentials
      @role_credentials ||= Aws::AssumeRoleCredentials.new(
        client: core_aws_client,
        role_arn: role_arn,
        role_session_name: role_session_name
      )
    end

    def core_aws_client
      @core_aws_client ||= Aws::STS::Client.new
    end
  end

  class CodeBuildClient < Client
    def call
      Aws::CodeBuild::Client.new(
        region: "eu-west-2",
        credentials: role_credentials
      )
    end
  end

  class SsmClient < Client
    def call
      Aws::SSM::Client.new(credentials: role_credentials)
    end
  end

  class SSMClientForCoreAwsAccount < SsmClient
    include AwsClientWrapper

    private def role_arn
      "arn:aws:iam::#{core_aws_account_id}:role/#{aws_role}"
    end

    private def core_aws_account_id
      Aws::STS::Client.new.get_caller_identity.account
    end
  end

  class SSMClientForInfrastructureAwsAccount < SsmClient
    include AwsClientWrapper

    attr_accessor :infrastructure

    def initialize(infrastructure:)
      self.infrastructure = infrastructure
    end

    private def role_arn
      "arn:aws:iam::#{infrastructure.account_id}:role/#{aws_role}"
    end
  end
end

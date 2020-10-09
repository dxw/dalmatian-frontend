module AWS
  include Aws::STS
  if ENV["DALMATIAN_AWS_ACCOUNT_ID"].nil?
    ENV["DALMATIAN_AWS_ACCOUNT_ID"] = Aws::STS::Client.new.get_caller_identity.account
  end

  if ENV["DALMATIAN_CI_PIPELINE"].nil?
    ENV["DALMATIAN_CI_PIPELINE"] = "ci-terraform-build-pipeline"
  end
end

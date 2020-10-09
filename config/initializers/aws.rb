module AWS
  include Aws::STS
  if ENV["DALMATIAN_AWS_ACCOUNT_ID"].nil?
    ENV["DALMATIAN_AWS_ACCOUNT_ID"] = Aws::STS::Client.new.get_caller_identity.account
  end
end

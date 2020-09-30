# frozen_string_literal: true

class BuildsController < ApplicationController
  def index
    @infrastructure = Infrastructure.find(infrastructure_id)
    role_credentials = Aws::AssumeRoleCredentials.new(
      client: Aws::STS::Client.new,
      role_arn: "arn:aws:iam::#{@infrastructure.account_id}:role/#{ENV["AWS_ROLE"]}",
      role_session_name: "role_session_name"
    )

    client = Aws::CodeBuild::Client.new(
      region: "eu-west-2",
      credentials: role_credentials
    )

    test_app_builds = client.list_builds_for_project(project_name: "dalmatian-ci-test-app")
    recent_builds = test_app_builds.ids.first(10)
    resp = client.batch_get_builds(ids: recent_builds)

    @builds = resp.builds
  end

  private

  def infrastructure_id
    params[:infrastructure_id]
  end
end

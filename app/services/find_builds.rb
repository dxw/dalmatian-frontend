class FindBuilds
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call
    client = CodeBuildClient.new(infrastructure: infrastructure).call
    test_app_builds = client.list_builds_for_project(project_name: "dalmatian-ci-test-app")
    recent_builds = test_app_builds.ids.first(10)
    resp = client.batch_get_builds(ids: recent_builds)
    resp.builds
  end
end

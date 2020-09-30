class FindDalmatianBuilds
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call
    builds_with_detail(build_ids: recent_build_ids)
  end

  private

  def client
    @client ||= CodeBuildClientForCoreAwsAccount.new.call
  end

  def project_builds
    client.list_builds_for_project(project_name: "dalmatian-ci-#{infrastructure.identifier}")
  end

  def recent_build_ids
    project_builds.ids.first(3)
  end

  def builds_with_detail(build_ids:)
    client.batch_get_builds(ids: build_ids).builds
  end
end

class FindServiceBuilds
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call
    results = {}
    infrastructure.service_names.each do |service_name|
      results[service_name] = {}

      infrastructure.environment_names.each do |environment_name|
        builds_ids = client.list_builds_for_project(
          project_name: "#{infrastructure.identifier}-#{service_name}-#{environment_name}-codebuild"
        ).ids.first(5)

        results[service_name][environment_name] = builds_with_detail(build_ids: builds_ids)
      end
    end
    results
  end

  private

  def client
    @client ||= CodeBuildClientForInfrastructureAwsAccount.new(infrastructure: infrastructure).call
  end

  def builds_with_detail(build_ids:)
    client.batch_get_builds(ids: build_ids).builds
  end
end

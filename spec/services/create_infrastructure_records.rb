require "rails_helper"

RSpec.describe CreateInfrastructureRecords do
  describe "#call" do
    it "returns infrastructure records for each infrastructure entity" do
      fake_config = File.read("spec/fixtures/dalmatian-config/single_infrastructure.yml")
      allow(File).to receive(:read).and_return(fake_config)

      result = described_class.new.call

      expect(result).to be_kind_of(Array)
      expect(result.first).to be_kind_of(Infrastructure)

      infrastructure = result.first

      expect(infrastructure.identifier).to eql("new-dedicated-cluster")
      expect(infrastructure.dalmatian_config_source).to eql(["git@github.com:dxw/awesome-app-dalmatian-config"])
      expect(infrastructure.account_id).to eql(123456789012)
      expect(infrastructure.cluster).to eql({"create" => true})
      expect(infrastructure.rds).to eql([
        {
          "identifier" => "testservice",
          "in_use_by" => ["test-service"],
          "engine" => "postgres",
          "instance_class" => "db.t2.micro",
          "engine_version" => "11.4",
          "allocated_storage" => 20,
          "db_name" => "testapp",
          "port" => 5432,
          "maintenance_window" => "mon:19:00-mon:19:30",
          "backup_window" => "09:00-10:00",
          "force_ssl" => true,
          "parameter_store_path_db_url_name" => "DATABASE_URL"
        }
      ])
      expect(infrastructure.elasticache_cluster).to eql([
        {
          "identifier" => "testredis",
          "in_use_by" => ["test-service"],
          "engine" => "redis",
          "node_type" => "cache.t2.micro",
          "node_count" => 1,
          "engine_version" => "5.0.6",
          "port" => 6379,
          "maintenance_window" => "mon:19:00-mon:22:00",
          "snapshot_window" => "09:00-10:00",
          "parameter_store_path_elasticache_cluster_url_name" => "REDIS_URL"
        }
      ])
      expect(infrastructure.services).to eql([
        {
          "name" => "test-service",
          "parameter_store_path" => {"staging" => "/test-path"},
          "parameter_store_key" => {"staging" => "arn:aws:kms:eu-west-2:000000000000:key/00000000-0000-0000-0000-000000000000"},
          "container_count" => "2",
          "cloudfront" => {
            "create" => true,
            "offline_page_http_status" => ["500", "501", "502", "503", "504"],
            "custom_origins" => {
              "staging" => [
                {"origin" => "test-media-staging.s3.amazonaws.com", "id" => "test-media-staging-s3"}
              ],
              "production" => [
                {"origin" => "test-media-production.s3.amazonaws.com", "id" => "test-media-production-s3"}
              ]
            },
            "custom_behaviors" => {
              "staging" => [
                {
                  "path_patterns" => ["/media/*"],
                  "target_origin_id" => "test-media-staging-s3",
                  "min_ttl" => 1200,
                  "default_ttl" => 3600,
                  "max_ttl" => 86400
                }
              ],
              "production" => [
                {
                  "path_patterns" => ["/media/*"],
                  "target_origin_id" => "test-media-production-s3",
                  "min_ttl" => 1200,
                  "default_ttl" => 3600,
                  "max_ttl" => 86400
                }
              ]
            }
          },
          "lb_ip_whitelist" => [{"name" => "public", "cidr" => "0.0.0.0/0"}],
          "health_check_path" => "/check",
          "health_check_grace_period" => "0",
          "domain_names" => {"staging" => ["example-domain-name.co.uk"]},
          "lb_ssl_certificate" => {"staging" => "arn:aws:acm:lb-region-0:000000000000:certificate/00000000-0000-0000-0000-000000000000"},
          "cloudfront_ssl_certificate" => {"staging" => "arn:aws:acm:us-east-1:000000000000:certificate/00000000-0000-0000-0000-000000000000"},
          "image_source" => "build_from_github_repo",
          "image_location" => "git@github.com:dxw/dalmatian-test-app",
          "buildspec" => "buildspec.yml",
          "container_port" => 3100,
          "container_command" => ["/docker-entrypoint.sh", "rails", "server"],
          "container_volumes" => [{"name" => "test-volume", "host_path" => "/mnt/test", "container_path" => "/test"}],
          "scheduled_tasks" => [
            {
              "name" => "test-scheduled-task",
              "command" => ["rake", "do:something"],
              "schedule_expression" => "cron(0 12 * * ? *)"
            }
          ]
        }
      ])
      expect(infrastructure.shared_loadbalancer).to eql([{"in_use_by" => ["test-service"], "name" => "test-lb-1"}])
      expect(infrastructure.environments).to eql({
        "production" => {"instance_type" => "t2.medium", "max_servers" => 4, "min_servers" => 2},
        "staging" => {"instance_type" => "t2.small", "max_servers" => 4, "min_servers" => 2, "track_revision" => "feature/experiment"}
      })
    end
  end
end

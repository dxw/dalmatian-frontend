feature "Users can see Dalmatian Core build information" do
  around do |example|
    ClimateControl.modify DALMATIAN_CI_PIPELINE: "dalmatian-deploys", DALMATIAN_AWS_ACCOUNT_ID: "123" do
      example.run
    end
  end

  let(:infrastructure) { Infrastructure.create(identifier: "dalmatian-deploys", account_id: "123") }
  let(:aws_code_pipeline_client) { stub_aws_code_pipeline_client(account_id: infrastructure.account_id) }

  scenario "shows the code pipelines for that infrastructure's account id" do
    fake_pipeline_state = Aws::CodePipeline::Types::GetPipelineStateOutput.new(
      pipeline_name: "dalmatian-deploys",
      stage_states: [
        Aws::CodePipeline::Types::StageState.new(
          stage_name: "Source",
          action_states: [
            Aws::CodePipeline::Types::ActionState.new(
              action_name: "Source",
              revision_url: "https://github.com/dxw/app/commit/123",
              latest_execution: Aws::CodePipeline::Types::ActionExecution.new(
                status: "Succeeded",
                summary: "Merge pull request #32 from dxw",
                last_status_change: Time.new(2019, 7, 3, 16, 9, 4, "+01:00"),
                external_execution_url: nil
              )
            )
          ]
        ),
        Aws::CodePipeline::Types::StageState.new(
          stage_name: "Build",
          action_states: [
            Aws::CodePipeline::Types::ActionState.new(
              action_name: "Build",
              latest_execution: Aws::CodePipeline::Types::ActionExecution.new(
                status: "Succeeded",
                summary: "Merge pull request #32 from dxw",
                last_status_change: Time.new(2020, 9, 3, 11, 11, 26, "+01:00"),
                external_execution_url: "https://console.aws.amazon.com/codebuild/home?region=eu-west-2#/builds/test-app-test-service-staging-codebuild:b68c1dd9-c2a3-4151-84fe-647ed77d11f4/view/new"
              )
            )
          ]
        ),
        Aws::CodePipeline::Types::StageState.new(
          stage_name: "Deploy",
          action_states: [
            Aws::CodePipeline::Types::ActionState.new(
              action_name: "Deploy",
              latest_execution: Aws::CodePipeline::Types::ActionExecution.new(
                status: "Succeeded",
                summary: "Merge pull request #32 from dxw",
                last_status_change: Time.new(2020, 9, 3, 11, 14, 1, "+01:00"),
                external_execution_url: "https://console.aws.amazon.com/ecs/home?region=eu-west-2#/clusters/test-app-staging/services/test-service/deployments"
              )
            )
          ]
        )
      ]
    )

    allow(aws_code_pipeline_client).to receive(:list_pipelines)
      .and_return(Aws::CodePipeline::Types::ListPipelinesOutput.new(
        pipelines: [
          Aws::CodePipeline::Types::PipelineSummary.new(
            name: "dalmatian-deploys"
          )
        ]
      ))

    allow(aws_code_pipeline_client).to receive(:get_pipeline_state)
      .with(name: "dalmatian-deploys")
      .and_return(fake_pipeline_state)

    visit root_path

    click_on("Dalmatian Core")

    expect(page).to have_content("dalmatian-deploys")

    within(".stage-source") do
      expect(page).to have_content("Source")
      expect(page).to have_content("Wed, 03 Jul 2019 16:09:04 +0100")
      expect(page).to have_content("Succeeded")
      expect(page).not_to have_link("View in AWS")
      expect(page).to have_link("View revision", href: "https://github.com/dxw/app/commit/123")
    end

    within(".stage-build") do
      expect(page).to have_content("Build")
      expect(page).to have_content("Thu, 03 Sep 2020 11:11:26 +0100")
      expect(page).to have_content("Succeeded")
      expect(page).to have_link("View in AWS", href: "https://console.aws.amazon.com/codebuild/home?region=eu-west-2#/builds/test-app-test-service-staging-codebuild:b68c1dd9-c2a3-4151-84fe-647ed77d11f4/view/new")
      expect(page).not_to have_link("View revision")
    end

    within(".stage-deploy") do
      expect(page).to have_content("Deploy")
      expect(page).to have_content("Thu, 03 Sep 2020 11:14:01 +0100")
      expect(page).to have_content("Succeeded")
      expect(page).to have_link("View in AWS", href: "https://console.aws.amazon.com/ecs/home?region=eu-west-2#/clusters/test-app-staging/services/test-service/deployments")
      expect(page).not_to have_link("View revision")
    end
  end

  context "when there are multiple actions for the same stage" do
    it "groups them in the same stage" do
      fake_pipeline_state = Aws::CodePipeline::Types::GetPipelineStateOutput.new(
        pipeline_name: "dalmatian-deploys",
        stage_states: [
          Aws::CodePipeline::Types::StageState.new(
            stage_name: "Build",
            action_states: [
              Aws::CodePipeline::Types::ActionState.new(
                action_name: "Build the first part",
                latest_execution: Aws::CodePipeline::Types::ActionExecution.new(
                  status: "Succeeded",
                  summary: "Merge pull request #32 from dxw",
                  last_status_change: Time.new(2019, 7, 3, 16, 9, 4, "+01:00"),
                  external_execution_url: "https://console.aws.amazon.com/codebuild/home?region=eu-west-2#/builds/test-app-test-service-staging-codebuild:111/view/new"
                )
              ),
              Aws::CodePipeline::Types::ActionState.new(
                action_name: "Build the second part",
                latest_execution: Aws::CodePipeline::Types::ActionExecution.new(
                  status: "Succeeded",
                  summary: "Merge pull request #32 from dxw",
                  last_status_change: Time.new(2019, 7, 3, 17, 9, 4, "+01:00"),
                  external_execution_url: "https://console.aws.amazon.com/codebuild/home?region=eu-west-2#/builds/test-app-test-service-staging-codebuild:222/view/new"
                )
              )
            ]
          )
        ]
      )

      allow(aws_code_pipeline_client).to receive(:list_pipelines)
        .and_return(Aws::CodePipeline::Types::ListPipelinesOutput.new(
          pipelines: [
            Aws::CodePipeline::Types::PipelineSummary.new(
              name: "dalmatian-deploys"
            )
          ]
        ))

      allow(aws_code_pipeline_client).to receive(:get_pipeline_state)
        .with(name: "dalmatian-deploys")
        .and_return(fake_pipeline_state)

      visit dalmatian_builds_path

      within(".stage-build") do
        expect(page).to have_content("Build the first part")
        expect(page).to have_content("Wed, 03 Jul 2019 16:09:04 +0100")
        expect(page).to have_content("Succeeded")
        expect(page).to have_link("View in AWS", href: "https://console.aws.amazon.com/codebuild/home?region=eu-west-2#/builds/test-app-test-service-staging-codebuild:111/view/new")

        expect(page).to have_content("Build the second part")
        expect(page).to have_content("Wed, 03 Jul 2019 17:09:04 +0100")
        expect(page).to have_content("Succeeded")
        expect(page).to have_link("View in AWS", href: "https://console.aws.amazon.com/codebuild/home?region=eu-west-2#/builds/test-app-test-service-staging-codebuild:222/view/new")
      end
    end
  end

  context "when the pipeline name doesn't include the infrastructure name" do
    let(:infrastructure) { Infrastructure.create(identifier: "relevant-app", account_id: "123") }

    it "is not included as a pipeline to the user" do
      allow(aws_code_pipeline_client).to receive(:list_pipelines)
        .and_return(Aws::CodePipeline::Types::ListPipelinesOutput.new(
          pipelines: [
            Aws::CodePipeline::Types::PipelineSummary.new(
              name: "relevant-app"
            ),
            Aws::CodePipeline::Types::PipelineSummary.new(
              name: "another-non-matching-name"
            )
          ]
        ))

      fake_pipeline_state = Aws::CodePipeline::Types::GetPipelineStateOutput.new(
        pipeline_name: "relevant-app",
        stage_states: [
          Aws::CodePipeline::Types::StageState.new(
            stage_name: "Source",
            action_states: [
              Aws::CodePipeline::Types::ActionState.new(
                action_name: "Source",
                latest_execution: Aws::CodePipeline::Types::ActionExecution.new(
                  status: "Succeeded",
                  summary: "Merge pull request #32 from dxw",
                  last_status_change: Time.new(2019, 7, 3, 16, 9, 4, "+01:00"),
                  external_execution_url: nil
                )
              )
            ]
          )
        ]
      )

      allow(aws_code_pipeline_client).to receive(:get_pipeline_state)
        .with(name: "relevant-app")
        .and_return(fake_pipeline_state)

      visit dalmatian_builds_path

      expect(aws_code_pipeline_client).not_to receive(:get_pipeline_state)
        .with(name: "another-non-matching-name")
    end
  end
end

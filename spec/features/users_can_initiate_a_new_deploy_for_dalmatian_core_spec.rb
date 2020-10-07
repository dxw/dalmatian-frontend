feature "Users can start a build for Dalmatian Core" do
  around do |example|
    ClimateControl.modify DALMATIAN_CI_PIPELINE: "dalmatian-deploys", DALMATIAN_AWS_ACCOUNT_ID: "345" do
      example.run
    end
  end

  let(:infrastructure) { Infrastructure.create(identifier: "dalmatian-deploys", account_id: "345") }
  let(:aws_code_pipeline_client) { stub_aws_code_pipeline_client(account_id: infrastructure.account_id) }

  scenario "User can execute a code pipeline to start" do
    stub_pipeline

    allow(aws_code_pipeline_client).to receive(:start_pipeline_execution).and_return(
      Aws::CodePipeline::Types::StartPipelineExecutionOutput.new(
        pipeline_execution_id: "123"
      )
    )
    visit dalmatian_builds_path

    click_on(I18n.t("button.execute"))

    expect(page).to have_content("CodePipeline 'dalmatian-deploys' has been executed")
  end

  scenario "User are told when an execution fails" do
    stub_pipeline

    allow(aws_code_pipeline_client).to receive(:start_pipeline_execution).and_raise(
      Aws::CodePipeline::Errors::PipelineNotFoundException.new(
        anything,
        "The account with id '123123123' does not include a pipeline with the name 'pipeline-name'"
      )
    )

    visit dalmatian_builds_path

    click_on(I18n.t("button.execute"))

    expect(page).to have_content(
      "CodePipeline 'dalmatian-deploys' failed because The account with id '123123123' does not include a pipeline with the name 'pipeline-name'"
    )
  end

  def stub_pipeline
    allow(aws_code_pipeline_client).to receive(:list_pipelines)
      .and_return(Aws::CodePipeline::Types::ListPipelinesOutput.new(
        pipelines: [
          Aws::CodePipeline::Types::PipelineSummary.new(
            name: "dalmatian-deploys"
          )
        ]
      ))

    fake_pipeline_state = Aws::CodePipeline::Types::GetPipelineStateOutput.new(
      pipeline_name: "dalmatian-deploys",
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
      .with(name: "dalmatian-deploys")
      .and_return(fake_pipeline_state)
  end
end

class PipelinePresenter < SimpleDelegator
  def name
    pipeline_name
  end

  def stages
    stage_states.map { |state| StagePresenter.new(state) }
  end
end

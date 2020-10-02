class StagePresenter < SimpleDelegator
  def name
    stage_name
  end

  def actions
    action_states.map { |action| ActionPresenter.new(action) }
  end
end

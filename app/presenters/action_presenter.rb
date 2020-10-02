class ActionPresenter < SimpleDelegator
  def name
    action_name
  end

  def last_status
    return latest_execution.status if latest_execution.present?
    nil
  end

  def card_class
    return nil unless last_status.present?
    "#{last_status.downcase}-card"
  end

  def last_time
    return latest_execution.last_status_change if latest_execution.present?
    nil
  end

  def last_summary
    return latest_execution.summary if latest_execution.present?
    nil
  end

  def last_external_execution_url
    return latest_execution.external_execution_url if latest_execution.present?
    nil
  end
end

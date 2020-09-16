# frozen_string_literal: true

module ApplicationHelper
  def active_link(path:)
    return "active" if path == request.path
  end
end

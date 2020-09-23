# frozen_string_literal: true

module ApplicationHelper
  def active_link(path:)
    return "active" if path == request.path
  end

  def present_sensitive_value(value)
    if ENV["HIDE_SECRETS_BY_DEFAULT"] == "true"
      I18n.t("obfuscation")
    else
      value
    end
  end
end

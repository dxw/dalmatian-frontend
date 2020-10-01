# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from Aws::STS::Errors::ExpiredToken, with: :expired_token

  def health_check
    render json: {rails: "OK"}, status: :ok
  end

  private

  def expired_token
    @error_message = "Your AWS token has expired. This happens every 12 hours. You can renew it by following <a href='https://github.com/dxw/dalmatian-frontend#prerequisites' target='_blank'>the dalmatian-mfa steps in the readme</a>."
    render "pages/error", status: 500
  end
end

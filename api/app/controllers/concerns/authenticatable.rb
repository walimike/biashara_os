module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate!
  end

  private

    def authenticate!
      token = bearer_token
      payload = JsonWebToken.decode(token)
      return render_unauthorized unless payload

      @current_user = User.find_by(id: payload[:user_id])
      return render_unauthorized unless @current_user

      @current_organization = @current_user.organization
    end

    def bearer_token
      header = request.headers["Authorization"].to_s
      header.split(" ").last if header.start_with?("Bearer ")
    end

    def render_unauthorized
      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    attr_reader :current_user, :current_organization
end

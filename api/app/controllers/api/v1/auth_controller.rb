module Api
  module V1
    class AuthController < ApplicationController
      def register
        ActiveRecord::Base.transaction do
          organization = Organization.create!(organization_params)
          user = organization.users.create!(user_params.merge(role: "owner"))
          token = JsonWebToken.encode(user_id: user.id, organization_id: organization.id)
          render json: auth_payload(user, token), status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end

      def login
        user = User.find_by(email: params[:email].to_s.strip.downcase)
        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id, organization_id: user.organization_id)
          render json: auth_payload(user, token)
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      private

        def organization_params
          params.require(:organization).permit(:name, :currency)
        end

        def user_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation)
        end

        def auth_payload(user, token)
          {
            token: token,
            user: user_json(user),
            organization: organization_json(user.organization)
          }
        end

        def user_json(user)
          {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role
          }
        end

        def organization_json(organization)
          {
            id: organization.id,
            name: organization.name,
            slug: organization.slug,
            currency: organization.currency,
            plan: organization.plan,
            enabled_modules: organization.enabled_modules
          }
        end
    end
  end
end

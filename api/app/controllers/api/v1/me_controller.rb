module Api
  module V1
    class MeController < BaseController
      def show
        render json: {
          user: {
            id: current_user.id,
            name: current_user.name,
            email: current_user.email,
            role: current_user.role
          },
          organization: {
            id: current_organization.id,
            name: current_organization.name,
            slug: current_organization.slug,
            currency: current_organization.currency,
            plan: current_organization.plan,
            enabled_modules: current_organization.enabled_modules
          }
        }
      end
    end
  end
end

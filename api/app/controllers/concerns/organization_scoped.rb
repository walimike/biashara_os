module OrganizationScoped
  extend ActiveSupport::Concern

  private

    def require_module!(mod)
      return if current_organization.module_enabled?(mod)

      render json: { error: "Module '#{mod}' is not enabled for this organization" }, status: :forbidden
    end
end

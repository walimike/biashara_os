module Api
  module V1
    class BaseController < ApplicationController
      include Authenticatable
      include OrganizationScoped
    end
  end
end

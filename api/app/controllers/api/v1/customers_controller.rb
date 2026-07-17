module Api
  module V1
    class CustomersController < BaseController
      before_action -> { require_module!("order_pad") }
      before_action :set_customer, only: [ :show, :update, :destroy ]

      def index
        customers = current_organization.customers.ordered
        customers = customers.where("name ILIKE :q OR phone ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
        render json: customers.map { |c| customer_json(c) }
      end

      def show
        render json: customer_json(@customer)
      end

      def create
        customer = current_organization.customers.create!(customer_params)
        render json: customer_json(customer), status: :created
      end

      def update
        @customer.update!(customer_params)
        render json: customer_json(@customer)
      end

      def destroy
        @customer.destroy!
        head :no_content
      end

      private

        def set_customer
          @customer = current_organization.customers.find(params[:id])
        end

        def customer_params
          params.require(:customer).permit(:name, :phone, :email, :notes)
        end

        def customer_json(customer)
          {
            id: customer.id,
            name: customer.name,
            phone: customer.phone,
            email: customer.email,
            notes: customer.notes
          }
        end
    end
  end
end

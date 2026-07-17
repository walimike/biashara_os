module Api
  module V1
    class OrdersController < BaseController
      before_action :set_order, only: [ :show, :update ]

      def index
        orders = current_organization.orders.includes(:customer, :order_items).recent
        orders = orders.where(source: params[:source]) if params[:source].present?
        orders = orders.where(status: params[:status]) if params[:status].present?
        orders = orders.where(payment_status: params[:payment_status]) if params[:payment_status].present?
        orders = orders.limit(params.fetch(:limit, 50))
        render json: orders.map { |o| order_json(o) }
      end

      def show
        render json: order_json(@order)
      end

      def create
        order = current_organization.orders.new(order_params)
        order.user = current_user
        order.save!
        order.recalculate_totals!
        render json: order_json(order.reload), status: :created
      end

      def update
        @order.update!(order_params)
        @order.recalculate_totals!
        render json: order_json(@order.reload)
      end

      private

        def set_order
          @order = current_organization.orders.includes(:customer, :order_items).find(params[:id])
        end

        def order_params
          params.require(:order).permit(
            :customer_id, :source, :status, :payment_method, :payment_status,
            :mpesa_reference, :notes,
            order_items_attributes: [ :id, :product_id, :name, :quantity, :unit_price_cents, :_destroy ]
          )
        end

        def order_json(order)
          {
            id: order.id,
            order_number: order.order_number,
            source: order.source,
            status: order.status,
            payment_method: order.payment_method,
            payment_status: order.payment_status,
            mpesa_reference: order.mpesa_reference,
            subtotal_cents: order.subtotal_cents,
            total_cents: order.total_cents,
            notes: order.notes,
            customer: order.customer && {
              id: order.customer.id,
              name: order.customer.name,
              phone: order.customer.phone
            },
            order_items: order.order_items.map do |item|
              {
                id: item.id,
                product_id: item.product_id,
                name: item.name,
                quantity: item.quantity,
                unit_price_cents: item.unit_price_cents,
                line_total_cents: item.line_total_cents
              }
            end,
            created_at: order.created_at
          }
        end
    end
  end
end

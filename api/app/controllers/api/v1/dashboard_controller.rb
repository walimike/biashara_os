module Api
  module V1
    class DashboardController < BaseController
      def show
        today_orders = current_organization.orders.today
        paid_today = today_orders.where(payment_status: "paid")

        render json: {
          today: {
            orders_count: today_orders.count,
            revenue_cents: paid_today.sum(:total_cents),
            unpaid_orders_count: today_orders.where(payment_status: "unpaid").count
          },
          modules: current_organization.enabled_modules
        }
      end
    end
  end
end

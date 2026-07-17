module Api
  module V1
    class ProductsController < BaseController
      before_action :set_product, only: [:show, :update, :destroy]

      def index
        products = current_organization.products.ordered
        products = products.active if params[:active_only] == "true"
        render json: products.map { |p| product_json(p) }
      end

      def show
        render json: product_json(@product)
      end

      def create
        product = current_organization.products.create!(product_params)
        render json: product_json(product), status: :created
      end

      def update
        @product.update!(product_params)
        render json: product_json(@product)
      end

      def destroy
        @product.update!(active: false)
        head :no_content
      end

      private

        def set_product
          @product = current_organization.products.find(params[:id])
        end

        def product_params
          params.require(:product).permit(:name, :sku, :price_cents, :stock_quantity, :active)
        end

        def product_json(product)
          {
            id: product.id,
            name: product.name,
            sku: product.sku,
            price_cents: product.price_cents,
            stock_quantity: product.stock_quantity,
            active: product.active
          }
        end
    end
  end
end

module Admin
  class OrdersController < AdminController
    def index
      begin
        @orders = Order.includes(:user, order_items: :product)
                      .order(created_at: :desc)
        @stats = {
          total_orders: Order.count,
          completed_orders: Order.where(status: 'completed').count,
          pending_orders: Order.where(status: 'pending').count,
          total_revenue: Order.where(status: 'completed').sum(:total_amount)
        }
        render json: {
          orders: @orders,
          stats: @stats
        }, 
               include: { 
                 user: { only: [:username, :email] },
                 order_items: {
                   include: {
                     product: { only: [:title, :image] }
                   }
                 }
               }
      rescue => e
        Rails.logger.error "Error in admin/orders#index: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: 'Internal server error' }, status: :internal_server_error
      end
    end

    def update
      begin
        @order = Order.find(params[:id])
        if @order.update(order_params)
          render json: @order, include: { user: { only: [:username, :email] } }
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error "Error in admin/orders#update: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: 'Internal server error' }, status: :internal_server_error
      end
    end

    def destroy
        @order = Order.find(params[:id])
        if @order.destroy
          render json: { message: "Order deleted successfully" }
        else
          render json: { error: "Failed to delete order" }, status: :unprocessable_entity
        end
      end

    private

    def order_params
      params.require(:order).permit(:status)
    end
  end
end 
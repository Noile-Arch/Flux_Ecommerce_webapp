module Admin
  class AdminController < ApplicationController
    before_action :authorize_admin

    def stats
      completed_orders = Order.where(status: 'completed')
      pending_orders = Order.where(status: 'pending')
      processing_orders = Order.where(status: 'processing')
      cancelled_orders = Order.where(status: 'cancelled')

      low_stock_products = Product.where('stock <= ?', 5)

      render json: {
        totalUsers: User.count,
        totalProducts: Product.all.count,
        totalOrders: Order.count,
        revenue: Order.where(status: 'completed').sum(:total_amount) || 0,
        pendingOrders: pending_orders.count,
        processingOrders: processing_orders.count,
        completedOrders: completed_orders.count,
        cancelledOrders: cancelled_orders.count,
        lowStockProducts: low_stock_products.count,
        outOfStockProducts: Product.where(stock: 0).count,
        lowStockItems: low_stock_products
          .select(:id, :title, :stock, :price, :category, :description, :image)
          .order(:stock)
          .limit(5)
          .map { |p| {
            id: p.id,
            title: p.title,
            stock: p.stock,
            price: p.price.to_f,
            category: p.category,
            description: p.description,
            image: p.image
          }},
        trends: {
          users: calculate_trend(User),
          orders: calculate_trend(Order),
          revenue: calculate_revenue_trend
        }
      }
    end

    private

    def authorize_admin
      unless current_user&.admin?
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end

    def calculate_trend(model)
      current = model.where('created_at >= ?', 1.month.ago).count
      previous = model.where(created_at: 2.months.ago..1.month.ago).count
      return 0 if previous.zero?
      ((current - previous).to_f / previous * 100).round
    end

    def calculate_revenue_trend
      current = Order.where(status: 'completed')
                    .where('created_at >= ?', 1.month.ago)
                    .sum(:total_amount)
      previous = Order.where(status: 'completed')
                     .where(created_at: 2.months.ago..1.month.ago)
                     .sum(:total_amount)
      return 0 if previous.zero?
      ((current - previous).to_f / previous * 100).round
    end
  end
end 
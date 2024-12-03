class AdminController < ApplicationController
  before_action :authorize_admin

  def products
    @products = Product.all
    render json: @products
  end

  def users
    @users = User.all
    render json: @users
  end

  def orders
    @orders = Order.includes(:user).all
    render json: @orders, include: { user: { only: [:username] } }
  end

  def create_product
    @product = Product.new(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_product
    @product = Product.find(params[:id])
    if @product.update(product_params)
      render json: @product
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def delete_product
    @product = Product.find(params[:id])
    @product.destroy
    head :no_content
  end

  def stats
    # Get all orders with different statuses
    completed_orders = Order.where(status: 'completed')
    pending_orders = Order.where(status: 'pending')
    processing_orders = Order.where(status: 'processing')
    cancelled_orders = Order.where(status: 'cancelled')

    # Get low stock products
    low_stock_products = Product.where('stock <= ?', 5)

    # Calculate total revenue from completed orders
    total_revenue = completed_orders.sum(:total_amount)

    # Build response manually
    response = {
      totalUsers: User.count,
      totalProducts: Product.count,
      totalOrders: Order.count,
      revenue: total_revenue,  # Use total_amount directly
      
      pendingOrders: pending_orders.count,
      processingOrders: processing_orders.count,
      completedOrders: completed_orders.count,
      cancelledOrders: cancelled_orders.count,
      
      lowStockProducts: low_stock_products.count,
      outOfStockProducts: Product.where(stock: 0).count,
      
      trends: {
        users: calculate_trend(User),
        orders: calculate_trend(Order),
        revenue: calculate_revenue_trend
      }.as_json,
      
      lowStockItems: low_stock_products
        .select(:id, :title, :stock, :price)
        .order(:stock)
        .limit(5)
        .map { |p| {
          id: p.id,
          title: p.title,
          stock: p.stock,
          price: p.price.to_f
        }},
      
      recentOrders: Order.includes(:user)
        .order(created_at: :desc)
        .limit(5)
        .map { |o| {
          id: o.id,
          status: o.status,
          total_amount: o.total_amount.to_f,
          created_at: o.created_at,
          user: {
            username: o.user.username
          }
        }}
    }

    render json: response
  end

  private

  def authorize_admin
    unless current_user&.admin?
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def product_params
    params.require(:product).permit(:title, :price, :description, :category, :image, :stock)
  end

  def calculate_trend(model)
    current = model.where('created_at >= ?', 1.month.ago).count
    previous = model.where(created_at: 2.months.ago..1.month.ago).count
    return 0 if previous.zero?
    ((current - previous).to_f / previous * 100).round
  end

  def calculate_revenue_trend
    current = Order.where(status: 'completed')
                  .sum(:total_amount)

    previous = Order.where(status: 'completed')
                   .sum(:total_amount)

    return 0 if previous.zero?
    ((current - previous).to_f / previous * 100).round
  end
end 
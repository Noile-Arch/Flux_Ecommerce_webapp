class OrdersController < ApplicationController
  before_action :authorize_request

  def create
    cart = current_user.cart
    
    return render json: { error: "Cart is empty" }, status: :unprocessable_entity if cart.cart_items.empty?
    
    ActiveRecord::Base.transaction do
      total = params[:cart_items].sum { |item| item[:quantity] * item[:price].to_i }
      
      order = current_user.orders.create!(
        total_amount: total,
        status: :pending
      )
      
      params[:cart_items].each do |item|
        order.order_items.create!(
          product_id: item[:product_id],
          quantity: item[:quantity],
          price: item[:price].to_i
        )
      end
      
      cart.cart_items.destroy_all
      
      render json: { 
        message: "Order placed successfully!", 
        order: { 
          id: order.id,
          total_amount: order.total_amount,
          status: order.status,
          created_at: order.created_at,
          items: order.order_items.map { |item|
            {
              id: item.id,
              title: item.product.title,
              quantity: item.quantity,
              price: item.price,
              total: item.quantity * item.price
            }
          }
        }
      }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update_status
    order = current_user.orders.find_by(id: params[:id])
    
    if order.nil?
      render json: { error: "Order not found" }, status: :not_found
      return
    end

    if order.update(status: params[:status])
      render json: { 
        message: "Order status updated successfully",
        order: {
          id: order.id,
          status: order.status
        }
      }
    else
      render json: { error: "Failed to update order status" }, status: :unprocessable_entity
    end
  end

  def index
    orders = current_user.orders.order(created_at: :desc)
    
    render json: {
      orders: orders.map { |order|
        {
          id: order.id,
          total_amount: order.total_amount,
          status: order.status,
          created_at: order.created_at,
          items: order.order_items.map { |item|
            {
              id: item.id,
              title: item.product.title,
              quantity: item.quantity,
              price: item.price,
              total: item.quantity * item.price
            }
          }
        }
      }
    }
  end

  private

  def calculate_total(cart_items)
    cart_items.sum { |item| item.product.price.to_f * item.quantity }
  end
end 
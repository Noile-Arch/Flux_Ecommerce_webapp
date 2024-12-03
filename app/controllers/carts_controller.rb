class CartsController < ApplicationController
  before_action :authorize_request

  # Add item to the cart
  def add_to_cart
    cart = current_user.cart || current_user.create_cart
    product = Product.find_by(id: params[:product_id])
  
    if product.nil?
      render json: { error: "Product not found." }, status: :not_found
      return
    end
  
    cart_item = cart.cart_items.find_by(product_id: product.id)
  
    # Check if the item already exists in the cart
    if cart_item
      render json: { message: "Item already exists in the cart.", cart_id: cart.id }, status: :ok
      return
    end
  
    quantity = params[:quantity].to_i
  
    if product.stock < quantity
      render json: { error: "Not enough stock available." }, status: :unprocessable_entity
      return
    end
  
    # Create a new cart item
    cart_item = cart.cart_items.new(
      product_id: product.id,
      quantity: quantity,
      product_details: product.slice(:id, :title, :price, :description, :category, :image, :stock, :ratingCount, :ratingRate)
    )
  
    if cart_item.save
      render json: { message: "Item added to cart successfully.", cart_id: cart.id }, status: :ok
    else
      render json: { error: cart_item.errors.full_messages }, status: :unprocessable_entity
    end
  end
  

  # Show user's cart
  def index
    cart = current_user.cart || current_user.create_cart
    render json: {
      cart_id: cart.id,
      total_quantity: cart.cart_items.sum(:quantity),
      items: cart.cart_items.map do |cart_item|
        {
          id: cart_item.product.id,
          title: cart_item.product.title,
          price: cart_item.product.price,
          description: cart_item.product.description,
          category: cart_item.product.category,
          image: cart_item.product.image,
          stock: cart_item.product.stock,
          ratingCount: cart_item.product.ratingCount,
          ratingRate: cart_item.product.ratingRate,
          quantity: cart_item.quantity
        }
      end
    }, status: :ok
  end

  # Remove item from the cart
  def remove_from_cart
    cart = current_user.cart
  
    if cart.nil?
      render json: { error: "Cart not found." }, status: :not_found
      return
    end
  
    # Extract product ID from parameters
    product_id = params[:cart_item_id]
  
    if product_id.nil?
      render json: { error: "Product ID is required." }, status: :unprocessable_entity
      return
    end
  
    # Find the cart_item where the product ID matches the one in product_details
    cart_item = cart.cart_items.find_by("product_details @> ?", { "id" => product_id }.to_json)
  
    if cart_item.nil?
      render json: { error: "Item not found in the cart." }, status: :not_found
      return
    end
  
    # Remove the cart item
    if cart_item.destroy
      render json: { message: "Item removed from cart successfully." }, status: :ok
    else
      render json: { error: "Failed to remove item from cart." }, status: :unprocessable_entity
    end
  end

  
  # Clear all items from the cart
  def clear_cart
    cart = current_user.cart
    if cart.present?
      cart.cart_items.destroy_all
      render json: { message: "Cart cleared successfully.", cart_id: cart.id }, status: :ok
    else
      render json: { error: "Cart is already empty." }, status: :not_found
    end
  end
end

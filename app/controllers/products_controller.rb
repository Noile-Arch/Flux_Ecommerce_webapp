class ProductsController < ApplicationController
  skip_before_action :authorize_request, only: [:index, :show, :by_category, :search]

  def index
    @products = Product.all
    render json: @products
  end

  def show
    @product = Product.find_by(id: params[:id])
    
    if @product
      render json: @product
    else
      render json: { error: "Product not found" }, status: :not_found
    end
  end

  def by_category
    Rails.logger.info "Category param: #{params[:category]}"
    
    category = params[:category].strip
    
    Rails.logger.info "Looking for category: #{category}"
    
    Rails.logger.info "Available categories: #{Product.distinct.pluck(:category)}"
    
    @products = Product.where(category: category)
    
    Rails.logger.info "Found products: #{@products.to_json}"
    
    if @products.empty?
      render json: { error: 'No products found in this category' }, status: :not_found
    else
      products_with_unique_ids = @products.map.with_index { |product, index| 
        product.as_json.merge(
          id: product.id.to_i,
          unique_key: "#{product.id}-#{index}"
        )
      }
      render json: products_with_unique_ids
    end
  end

  def search
    query = params[:query].downcase
    Rails.logger.info "Search query: #{query}"

    @products = Product.where('LOWER(title) LIKE ? OR LOWER(description) LIKE ?', 
                            "%#{query}%", "%#{query}%")
                      .or(Product.where(category: query))

    Rails.logger.info "Found products: #{@products.to_json}"

    if @products.empty?
      render json: []
    else
      products_with_unique_ids = @products.map.with_index { |product, index| 
        product.as_json.merge(
          id: product.id.to_i,
          search_key: "search-#{product.id}-#{Time.now.to_i}-#{index}"
        )
      }
      render json: products_with_unique_ids
    end
  end
end

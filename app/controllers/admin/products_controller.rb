module Admin
  class ProductsController < AdminController
    def index
      @products = Product.all
      render json: @products
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        render json: @product, status: :created
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      @product = Product.find_by(id: params[:uuid])
      if @product&.update(product_params)
        render json: @product
      else
        render json: { errors: @product&.errors&.full_messages || ['Product not found'] }, 
               status: @product ? :unprocessable_entity : :not_found
      end
    end

    def destroy
      @product = Product.find_by(id: params[:uuid])
      if @product&.destroy
        head :no_content
      else
        render json: { error: 'Product not found' }, status: :not_found
      end
    end

    private

    def product_params
      params.require(:product).permit(:title, :price, :description, :category, :image, :stock)
    end
  end
end 
class ProductsController < ApplicationController
  def index
    @categories = Category.all
    @products = Product.all

  @sort_options = [
    ["Mặc định", ""],
    ["Giá tăng dần", ""],
    ["Giá giảm dần", ""],
  ]

  end

  def show
    @product = Product.find(params[:id])
    @related_products = Product.where(category_id: @product.category_id).where.not(id: @product.id).limit(8)

  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :image_url, :category_id)
  end

end

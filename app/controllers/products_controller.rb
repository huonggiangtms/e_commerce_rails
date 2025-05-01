class ProductsController < ApplicationController
  def index
    @categories = Category.all
    @products = Product.all

  # Thêm mảng sắp xếp vào đây
  @sort_options = [
    ["Mặc định", ""],
    ["Giá tăng dần", "price_asc"],
    ["Giá giảm dần", "price_desc"],
  ]

  end

  def show
    @product = Product.find(params[:id])
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :image_url, :category_id)
  end

end

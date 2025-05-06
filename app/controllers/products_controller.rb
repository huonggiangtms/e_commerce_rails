class ProductsController < ApplicationController
  def index
    @q = Product.ransack(params[:q])
    @products = @q.result(distinct: true).includes(:category)

    @categories = Category.all
    @sort_options = [
      [ "Mặc định", nil ],
      [ "Giá tăng dần", "price asc" ],
      [ "Giá giảm dần", "price desc" ],
      [ "Mới nhất", "created_at desc" ],
      [ "Cũ nhất", "created_at asc" ]
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

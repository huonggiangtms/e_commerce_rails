class Admin::CrawledProductsController < ApplicationController
  before_action :set_crawled_product, only: [ :show, :edit, :update, :approve, :destroy ]

  def index
    @crawled_products = CrawledProduct.order(created_at: :desc)

    if params[:status].present?
      @crawled_products = @crawled_products.where(status: params[:status])
    end
  end

  def show
  end

  def edit
  end

  def update
    if @crawled_product.update(crawled_product_params)
      redirect_to admin_crawled_products_path, notice: "Sản phẩm đã được cập nhật."
    else
      render :edit, alert: "Không thể cập nhật sản phẩm."
    end
  end

  def approve
    @crawled_product = CrawledProduct.find(params[:id])
    if @crawled_product.status == "approved"
      redirect_to admin_crawled_products_path, alert: "Sản phẩm đã được duyệt rồi!"
      return
    end
    category = Category.find_or_create_by(name: @crawled_product.category_name)

    product = Product.new(
      name: @crawled_product.name,
      description: @crawled_product.description,
      price: @crawled_product.price,
      stock: @crawled_product.stock,
      image_url: @crawled_product.image_url,
      category: category,
      crawled_product: @crawled_product
    )

    if product.save
      @crawled_product.update(status: "approved")
      redirect_to admin_crawled_products_path, notice: "Product approved!"
    else
      redirect_to admin_crawled_products_path, alert: "Failed to approve product."
    end
  end

  def destroy
    @crawled_product.destroy
    redirect_to admin_crawled_products_path, notice: "Product deleted"
  end

  def manual_crawl
  end

  def crawl_manual
    url = params[:url]

    if url.blank?
      redirect_to manual_crawl_admin_crawled_products_path, alert: "Vui lòng nhập URL"
      return
    end

    begin
      crawler = ProductCrawler.new(url)
      crawler.crawl_and_save

      redirect_to admin_crawled_products_path, notice: "Crawl sản phẩm thành công!"
    rescue => e
      redirect_to manual_crawl_admin_crawled_products_path, alert: "Lỗi khi crawl: #{e.message}"
    end
  end
  private

  def set_crawled_product
    @crawled_product = CrawledProduct.find(params[:id])
  end

  def crawled_product_params
    params.require(:crawled_product).permit(:name, :description, :price, :image_url, :category_name)
  end
end

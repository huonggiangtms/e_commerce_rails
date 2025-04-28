class HomeController < ApplicationController
  def index
    @banner = Banner.where(active: true).order(created_at: :desc).first
    @products = Product.where('stock > 0').limit(8).order(stock: :desc)
  end
end

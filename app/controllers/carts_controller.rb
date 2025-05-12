class CartsController < ApplicationController
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:product)
  end

  private

  def set_cart
    if current_user&.cart
      @cart = current_user.cart
      session[:cart_id] = @cart.id
    else
      @cart = Cart.find_by(id: session[:cart_id]) || Cart.create(user: current_user)
      session[:cart_id] = @cart.id
    end
  end
end

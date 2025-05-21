class CartItemsController < ApplicationController
  before_action :set_cart
  before_action :set_cart_item, only: [ :update, :destroy ]

  def show
    render json: { product_price: @cart_item.product.price }
  end

  def create
    product = Product.find(params[:cart_item][:product_id])
    quantity_to_add = params[:cart_item][:quantity].to_i

    cart_item = @cart.cart_items.find_or_initialize_by(product: product)
    current_quantity = cart_item.persisted? ? cart_item.quantity : 0
    new_quantity = current_quantity + quantity_to_add

    if new_quantity > product.stock
      flash[:alert] = "Sản phẩm này hiện chỉ còn #{product.stock} sản phẩm trong kho. Bạn đã có #{current_quantity}
      sản phẩm trong giỏ, không thể thêm thêm #{quantity_to_add} sản phẩm nữa."
    else
      cart_item.quantity = new_quantity
      cart_item.price = product.price

      if cart_item.save
        flash[:notice] = "Đã thêm #{product.name} vào giỏ hàng!"
      else
        flash[:alert] = cart_item.errors.full_messages.join(", ")
      end
    end

    redirect_back fallback_location: products_path
  end

  def update
    @cart_item.quantity = params[:cart_item][:quantity].to_i

    if @cart_item.save
      flash[:notice] = "Cập nhật số lượng thành công!"
    else
      flash[:alert] = @cart_item.errors.full_messages.join(", ")
    end

    redirect_to cart_path
  end

  def destroy
    @cart_item.destroy
    flash[:notice] = "Đã xóa sản phẩm khỏi giỏ hàng!"
    redirect_to cart_path
  end

  private

  def set_cart
    if current_user&.cart
      @cart = current_user.cart
      session[:cart_id] = @cart.id
    else
      @cart = Cart.find_by(id: session[:cart_id])
      unless @cart
        @cart = Cart.create(user: current_user)
        session[:cart_id] = @cart.id
      end
    end
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end
end

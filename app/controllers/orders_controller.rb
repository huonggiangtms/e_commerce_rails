class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ], if: :stripe_webhook?

  def index
    @orders = current_user.orders.order(created_at: :desc).includes(:order_items)
  end

  def new
    @cart = current_user.cart
    @order = Order.new
    @cart_items = @cart.cart_items.includes(:product)
    @total_price = @cart_items.sum { |item| item.quantity * item.product.price }
  end

  def create
    if stripe_webhook?
      handle_stripe_webhook
    else
      handle_order_creation
    end
  end

  def show
    @order = Order.find(params[:id])
    @order_items = @order.order_items.includes(:product)
  end

  private

  def stripe_webhook?
    request.headers["Stripe-Signature"].present?
  end

  def handle_stripe_webhook
    Rails.logger.info "Nhận webhook từ Stripe: #{request.headers["Stripe-Signature"]}"

    payload = request.body.read
    sig_header = request.headers["Stripe-Signature"]
    webhook_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
      Rails.logger.info "Sự kiện webhook: #{event["type"]}"
    rescue JSON::ParserError => e
      Rails.logger.error "Lỗi phân tích JSON: #{e.message}"
      head :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Xác minh thất bại: #{e.message}"
      head :bad_request
      return
    end

    if event["type"] == "checkout.session.completed"
      session = event["data"]["object"]
      order_id = session["client_reference_id"]
      order = Order.find_by(id: order_id)

      unless order
        Rails.logger.error "Không tìm thấy đơn hàng với client_reference_id: #{order_id}"
        head :not_found
        return
      end

      if order.status == "pending"
        begin
          ActiveRecord::Base.transaction do
            order.update!(status: "paid")
            Rails.logger.info "Cập nhật trạng thái đơn hàng #{order.id} thành 'paid'"

            cart = order.cart
            if cart.present?
              # Check tồn kho trước khi tạo
              cart.cart_items.includes(:product).each do |cart_item|
                product = cart_item.product
                if product.stock < cart_item.quantity
                  Rails.logger.error "Sản phẩm #{product.name} không đủ tồn kho: Yêu cầu #{cart_item.quantity}, tồn kho #{product.stock}"
                  raise ActiveRecord::Rollback, "Sản phẩm #{product.name} không đủ tồn kho"
                end
              end

              # Tạo OrderItem và cập nhật tồn kho
              cart.cart_items.includes(:product).each do |cart_item|
                OrderItem.create!(
                  order_id: order.id,
                  product_id: cart_item.product_id,
                  quantity: cart_item.quantity,
                  unit_price: cart_item.product.price.to_i
                )

                cart_item.product.update!(stock: cart_item.product.stock - cart_item.quantity)
                Rails.logger.info "Giảm tồn kho sản phẩm #{cart_item.product.name}: #{cart_item.quantity}"
              end

              cart.cart_items.destroy_all
              Rails.logger.info "Xoá giỏ hàng cho đơn hàng #{order.id}"
            else
              Rails.logger.warn "Đơn hàng #{order.id} không có giỏ hàng liên kết"
            end
          end
        rescue StandardError => e
          Rails.logger.error "Lỗi xử lý đơn hàng #{order.id}: #{e.message}"
          head :unprocessable_entity
          return
        end
      else
        Rails.logger.warn "Đơn hàng #{order.id} không ở trạng thái chờ xử lý"
      end
    else
      Rails.logger.info "Loại sự kiện chưa xử lý: #{event["type"]}"
    end

    head :ok
  end

  def handle_order_creation
    @cart = current_user.cart
    @order = Order.new(order_params)
    @order.user_id = current_user.id
    @order.cart_id = @cart.id
    @total_price = @cart.cart_items.sum { |item| item.quantity * item.product.price }
    @order.total_price = @total_price
    @order.status = "pending"

    begin
      ActiveRecord::Base.transaction do
        # Chẹck tồn kho
        @cart.cart_items.includes(:product).each do |cart_item|
          product = cart_item.product
          if product.stock < cart_item.quantity
            Rails.logger.error "Sản phẩm #{product.name} không đủ tồn kho: Yêu cầu #{cart_item.quantity}, tồn kho #{product.stock}"
            raise ActiveRecord::Rollback, "Sản phẩm #{product.name} không đủ tồn kho"
          end
        end

        if @order.save
          Rails.logger.info "Lưu đơn hàng thành công: #{@order.id}"

          if @order.payment_method == "stripe"
            create_stripe_session
            Rails.logger.info "Tạo phiên thanh toán Stripe với mã đơn hàng: #{@order.id}"
            redirect_to @stripe_session.url, allow_other_host: true
          else
            # Tạo OrderItem và cập nhật tồn kho
            @cart.cart_items.each do |cart_item|
              OrderItem.create!(
                order_id: @order.id,
                product_id: cart_item.product_id,
                quantity: cart_item.quantity,
                unit_price: cart_item.product.price.to_i
              )

              cart_item.product.update!(stock: cart_item.product.stock - cart_item.quantity)
              Rails.logger.info "Giảm tồn kho sản phẩm #{cart_item.product.name}: #{cart_item.quantity}"
            end
            @cart.cart_items.destroy_all
            redirect_to order_path(@order), notice: "Đặt hàng thành công với phương thức thanh toán khi nhận hàng (COD)."
          end
        else
          Rails.logger.error "Lưu đơn hàng thất bại: #{@order.errors.full_messages}"
          raise ActiveRecord::Rollback
        end
      end
    rescue StandardError => e
      Rails.logger.error "Lỗi xử lý đơn hàng: #{e.message}"
      @cart_items = @cart.cart_items.includes(:product)
      @total_price = @cart_items.sum { |item| item.quantity * item.product.price }
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    end
  end

  def order_params
    params.require(:order).permit(:name, :phone, :address, :payment_method)
  end

  def create_stripe_session
    @stripe_session = Stripe::Checkout::Session.create({
      payment_method_types: ["card"],
      line_items: @cart.cart_items.map do |item|
        {
          price_data: {
            currency: "vnd",
            product_data: {
              name: item.product.name
            },
            unit_amount: item.product.price.to_i
          },
          quantity: item.quantity
        }
      end,
      mode: "payment",
      success_url: order_url(@order, host: "localhost:3000"),
      cancel_url: new_order_url(host: "localhost:3000"),
      client_reference_id: @order.id.to_s
    })
  end
end

class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [:show, :update]

  def index
    @orders = Order.all.order(created_at: :desc)
  end

  def show
    @order = Order.includes(order_items: :product).find(params[:id])
  end

  def update
    if params[:order][:status] == "cancelled" && @order.cancellation_requested?
      if @order.update(order_params)
        begin
          OrderMailer.cancellation_confirmed_notification(@order).deliver_now
          Rails.logger.info "Sent cancellation confirmation email for order #{@order.id}"
        rescue StandardError => e
          Rails.logger.error "Failed to send cancellation confirmation email for order #{@order.id}: #{e.message}"
        end
        redirect_to admin_orders_path, notice: "Đã hủy đơn hàng thành công."
      else
        redirect_to admin_orders_path, alert: "Hủy đơn hàng thất bại."
      end
    elsif @order.update(order_params)
      if @order.saved_change_to_status? && @order.confirmed?
        begin
          OrderMailer.confirmed_notification(@order).deliver_now
          Rails.logger.info "Sent confirmation email for order #{@order.id}"
        rescue StandardError => e
          Rails.logger.error "Failed to send confirmation email for order #{@order.id}: #{e.message}"
        end
      end
      redirect_to admin_orders_path, notice: "Đã cập nhật đơn hàng thành công."
    else
      redirect_to admin_orders_path, alert: "Cập nhật đơn hàng thất bại."
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end
end

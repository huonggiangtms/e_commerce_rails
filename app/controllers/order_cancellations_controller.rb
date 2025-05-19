class OrderCancellationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [ :create ]

  def create
    if @order.can_request_cancellation?
      begin
        ActiveRecord::Base.transaction do
          @order.update!(cancellation_requested: true)
          Rails.logger.info "Updated cancellation_requested to true for order #{@order.id}"
        end
        OrderMailer.cancellation_requested_notification(@order).deliver_now
        Rails.logger.info "Sent cancellation request email for order #{@order.id}"
        redirect_to order_path(@order), notice: "Yêu cầu hủy đơn hàng đã được gửi."
      rescue StandardError => e
        Rails.logger.error "Failed to process cancellation request for order #{@order.id}: #{e.message}"
        redirect_to order_path(@order), alert: "Không thể gửi yêu cầu hủy đơn hàng: #{e.message}"
      end
    else
      Rails.logger.warn "Order #{@order.id} cannot be cancelled: invalid status or already requested"
      redirect_to order_path(@order), alert: "Không thể yêu cầu hủy đơn hàng này."
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Order not found or not authorized for user #{current_user.id}: #{params[:order_id]}"
    redirect_to orders_path, alert: "Đơn hàng không tồn tại hoặc bạn không có quyền truy cập."
  end
end

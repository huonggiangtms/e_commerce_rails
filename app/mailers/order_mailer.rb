class OrderMailer < ApplicationMailer
  def confirmed_notification(order)
    @order = order
    @user = order.user
    mail to: @user.email, subject: "Đơn hàng ##{order.id} của bạn đã được xác nhận"
  end

  def cancellation_requested_notification(order)
    @order = order
    @user = order.user
    mail to: @user.email, subject: "Yêu cầu hủy đơn hàng ##{order.id} đã được gửi"
  end

  def cancellation_confirmed_notification(order)
    @order = order
    @user = order.user
    mail to: @user.email, subject: "Đơn hàng ##{order.id} của bạn đã được hủy"
  end
end

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest (chưa đăng nhập)

    if user.has_role?(:admin)
      can :manage, :all

    elsif user.has_role?(:user)
      can :read, Product     # User có thể xem sản phẩm
      can :read, Category    # User có thể xem danh mục sản phẩm
      can :manage, Cart      # User có thể quản lý giỏ hàng (thêm, sửa, xóa sản phẩm trong giỏ hàng)
      can :manage, Order     # User có thể tạo, chỉnh sửa và thanh toán đơn hàng
    else
      # Guest chưa đăng nhập vẫn xem được sản phẩm và danh mục
      can :read, Product     # Guest có thể xem sản phẩm
      can :read, Category    # Guest có thể xem danh mục sản phẩm
    end
  end
end

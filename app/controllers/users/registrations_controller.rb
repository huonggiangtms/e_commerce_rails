class Users::RegistrationsController < Devise::RegistrationsController
  # Override phương thức sau khi đăng ký thành công để chuyển đến trang đăng nhập
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :check_admin, if: :admin_page?

  private

  def check_admin
    unless current_user && current_user.has_role?(:admin)
      redirect_to root_path, alert: "You do not have permission to access this page."
    end
  end

  def admin_page?
    request.path.start_with?("/admin")
  end
end

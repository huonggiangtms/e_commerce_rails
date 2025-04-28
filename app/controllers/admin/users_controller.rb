class Admin::UsersController < ApplicationController
  before_action :check_admin, if: :admin_page?

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    # Cập nhật role thủ công từ form
    if params[:role].present?
      @user.roles = [Role.find_by(name: params[:role])] # Chỉ một role, dùng mảng để gán
    end

    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated!"
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted!"
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end

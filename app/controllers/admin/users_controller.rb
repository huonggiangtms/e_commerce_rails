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

    if params[:role].present?
      @user.roles = [ Role.find_by(name: params[:role]) ]
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

class Admin::BannersController < ApplicationController
  before_action :check_admin, if: :admin_page?

  def index
    @banners = Banner.all

    if params[:active].present?
      if params[:active] == 'true'
        @banners = @banners.where(active: true)
      elsif params[:active] == 'false'
        @banners = @banners.where(active: false)
      end
    end
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(banner_params)
    if @banner.save
      redirect_to admin_banners_path, notice: "Banner created successfully!"
    else
      render :new
    end
  end

  def edit
    @banner = Banner.find(params[:id])
  end

  def update
    @banner = Banner.find(params[:id])
    if @banner.update(banner_params)
      redirect_to admin_banners_path, notice: "Banner updated successfully!"
    else
      render :edit
    end
  end

  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy
    redirect_to admin_banners_path, notice: "Banner deleted successfully!"
  end

  private

  def banner_params
    params.require(:banner).permit(:title, :description, :active, :image) # Đảm bảo permit :image
  end
end

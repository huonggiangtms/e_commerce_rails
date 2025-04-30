class HomeController < ApplicationController
  def index
    @banner = Banner.where(active: true).order(created_at: :desc).first
  end
end

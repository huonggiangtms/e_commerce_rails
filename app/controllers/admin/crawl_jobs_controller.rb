class Admin::CrawlJobsController < ApplicationController
  def index
    @crawl_jobs = CrawlJob.all
  end

  def new
    @crawl_job = CrawlJob.new
  end

  def create
    @crawl_job = CrawlJob.new(crawl_job_params)
    if @crawl_job.save
      redirect_to admin_crawl_jobs_path, notice: "Crawl job đã được tạo!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @crawl_job = CrawlJob.find(params[:id])
  end

  def update
    @crawl_job = CrawlJob.find(params[:id])
    if @crawl_job.update(crawl_job_params)
      redirect_to admin_crawl_jobs_path, notice: "Crawl job đã được cập nhật!"
    else
      render :edit
    end
  end

  def destroy
    @crawl_job = CrawlJob.find(params[:id])
    if @crawl_job.destroy
      redirect_to admin_crawl_jobs_path, notice: "Crawl job đã được xóa!"
    else
      redirect_to admin_crawl_jobs_path, alert: "Không thể xóa Crawl job."
    end
  end

  private

  def crawl_job_params
    params.require(:crawl_job).permit(:url, :schedule, :active)
  end
end

class ProjectsController < ApplicationController
  http_basic_authenticate_with name: ENV['BASIC_AUTH_USER'], password: ENV['BASIC_AUTH_PASS']
  require 'wistia_library'

  def index
    @projects = Project.all
    @project = Project.new
  end

  def fetch_project_from_wistia
    # call wistia, create project, store videos
    @project = Project.new(project_params)
    if @project.save
      wistia_project = WistiaLibrary.call_wistia_with_hashed_id('projects', @project.hashed_id)
      medias = wistia_project['medias']
      medias.each do |media|
        Video.create(project: @project, name: media['name'], hashed_id: media['hashed_id'])
      end
      @project.update_attributes(name: wistia_project['name'], video_count: @project.videos.count)
      flash[:success] = "You did it!"
      redirect_to '/'
    else
      flash[:error] = "That didn't work. Check the logs if you think it should have."
      redirect_to '/'
    end
  end

  def fetch_video_urls_from_wistia
    # call wistia for each project video and update with URL
    WistiaMediaWorker.perform_async(params[:project_id])
    flash[:success] = "Job started. Check Sidekiq."
    redirect_to '/'
  end

  def download
    @project = Project.find(params[:project_id])
    @videos = Video.where(project_id: params[:project_id])
    
    respond_to do |format|
      format.csv { send_data @videos.to_csv, filename: "videos-#{@project.id}-#{@project.hashed_id}.csv" }
    end
  end

  def destroy
    if Project.find(params[:id]).destroy
      flash[:success] = "Project was deleted"
      redirect_to '/'
    else
      flash[:error] = "Error deleting project"
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :hashed_id)
  end

end

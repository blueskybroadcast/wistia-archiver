class ProjectsController < ApplicationController
  http_basic_authenticate_with name: ENV['BASIC_AUTH_USER'], password: ENV['BASIC_AUTH_PASS']

  def index
    @projects = Project.all
    @project = Project.new
  end

  def fetch_project_from_wistia
    # call wistia, create project, store videos
    @project = Project.new(project_params)
    if @project.save
      wistia_project = get_project(@project.hashed_id)
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
    @project = Project.find(params[:project_id])
    @project.videos.each do |video|
      media = get_media(video.hashed_id)
      assets = media['assets'].to_ary
      original_file_asset = assets.select { |asset| asset['type'] == 'OriginalFile' }
      video.update_attributes(url: original_file_asset.first['url'])
    end
    flash[:success] = "Finished!"
    redirect_to '/'
  end

  def download
    @project = Project.find(params[:project_id])
    @videos = Video.where(project_id: params[:project_id])
    
    respond_to do |format|
      format.csv { send_data @videos.to_csv, filename: "videos-#{@project.id}-#{@project.hashed_id}.csv" }
    end
  end

  private

  def call_wistia_with_hashed_id(resource, hashed_id)
    response = RestClient.get "https://api.wistia.com/v1/#{resource}/#{hashed_id}.json", { :Authorization => "Bearer #{ENV['WISTIA_API_KEY']}" }
    Rails.logger.info "++++++++ CALLING WISTIA: resource: #{resource}, hashed_id: #{hashed_id}"
    JSON.parse(response.body)
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "!!!!!!!! ERROR CALLING WISTIA: #{e}; #{e.response}, resource: #{resource}, hashed_id: #{hashed_id}"
  end

  def get_project(hashed_id)
    call_wistia_with_hashed_id('projects', hashed_id)
  end

  def get_media(hashed_id)
    call_wistia_with_hashed_id('medias', hashed_id)
  end

  def project_params
    params.require(:project).permit(:name, :hashed_id)
  end

end

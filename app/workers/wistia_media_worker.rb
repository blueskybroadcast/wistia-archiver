class WistiaMediaWorker
  include Sidekiq::Worker
  require 'wistia_library'

  def perform(project_id)
    project = Project.find(project_id)
    project.videos.each do |video|
      media = WistiaLibrary.call_wistia_with_hashed_id('medias', video.hashed_id)
      assets = media['assets'].to_ary
      original_file_asset = assets.select { |asset| asset['type'] == 'OriginalFile' }
      video.update_attributes(url: original_file_asset.first['url'])
      sleep(0.7)
    end
  end

end

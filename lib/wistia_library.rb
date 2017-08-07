class WistiaLibrary

  def self.call_wistia_with_hashed_id(resource, hashed_id)
    response = RestClient.get "https://api.wistia.com/v1/#{resource}/#{hashed_id}.json", { :Authorization => "Bearer #{ENV['WISTIA_API_KEY']}" }
    Rails.logger.info "++++++++ CALLING WISTIA: resource: #{resource}, hashed_id: #{hashed_id}"
    JSON.parse(response.body)
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "!!!!!!!! ERROR CALLING WISTIA: #{e}; #{e.response}, resource: #{resource}, hashed_id: #{hashed_id}"
  end

end

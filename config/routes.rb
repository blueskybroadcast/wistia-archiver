Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'projects#index'
  post 'wistia-project' => 'projects#fetch_project_from_wistia', as: :fetch_project_from_wistia
  post 'wistia-medias/:project_id' => 'projects#fetch_video_urls_from_wistia', as: :fetch_video_urls_from_wistia
  get 'download/:project_id' => 'projects#download', as: :download_project_csv
  delete 'projects/:id' => 'projects#destroy', as: :projects_delete
end

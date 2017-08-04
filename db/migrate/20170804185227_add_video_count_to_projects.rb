class AddVideoCountToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :video_count, :integer
  end
end

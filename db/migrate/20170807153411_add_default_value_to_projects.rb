class AddDefaultValueToProjects < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:projects, :video_count, 0)
  end
end

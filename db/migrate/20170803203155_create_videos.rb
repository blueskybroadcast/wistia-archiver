class CreateVideos < ActiveRecord::Migration[5.1]
  def change
    create_table :videos do |t|
      t.references :project, foreign_key: true
      t.string :name
      t.string :hashed_id
      t.string :url

      t.timestamps
    end
  end
end

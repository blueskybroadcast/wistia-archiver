class Video < ApplicationRecord
  belongs_to :project

  def self.to_csv
    attributes = %w{project_id name hashed_id url}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      current_scope.each do |video|
        csv << attributes.map{ |attr| video.send(attr) }
      end
    end
  end

end

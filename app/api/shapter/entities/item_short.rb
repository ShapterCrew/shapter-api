module Shapter
  module Entities
    class ItemShort < Grape::Entity
      expose :name
      expose :pretty_id, as: :id
      expose :comments_count    
      expose :subscribers_count 
      #expose :avg_quality_score 
      #expose :avg_work_score    
      expose :front_avg_diag, as: :averaged_diagram
      expose :diagrams_count
    end
  end
end




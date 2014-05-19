module Shapter
  module Entities
    class ItemShort < Grape::Entity
      expose :diagrams_count
      expose :name
      expose :pretty_id, as: :id
      expose :comments_count    
      expose :subscribers_count 
      expose :front_avg_diag, as: :averaged_diagram
    end
  end
end




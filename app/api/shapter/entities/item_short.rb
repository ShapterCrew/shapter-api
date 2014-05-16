module Shapter
  module Entities
    class ItemShort < Grape::Entity
      expose :name
      expose :pretty_id, as: :id
      expose :comments_count    unless {format: :id_only}
      expose :subscribers_count unless {format: :id_only}
      expose :avg_quality_score unless {format: :id_only}
      expose :avg_work_score    unless {format: :id_only}
      expose :front_avg_diag, as: :averaged_diagram
    end
  end
end




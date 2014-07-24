module Shapter
  module Entities
    class School < Grape::Entity
      expose :pretty_id, as: :id
      expose :best_comments, if: lambda{|u,o| o[:entity_options]["school"][:best_comments]} do |school,ops|
        school.best_comments(ops[:entity_options]["school"][:best_comments_count])
      end

      expose :students_count, if: lambda{|s, o| o[:entity_options]["school"][:students_count]}
      expose :comments_count, if: lambda{|s, o| o[:entity_options]["school"][:comments_count]}
      expose :diagrams_count, if: lambda{|s, o| o[:entity_options]["school"][:diagrams_count]}
      expose :img_url       , if: lambda{|s, o| o[:entity_options]["school"][:img_url]}
      expose :fill_rate     , if: lambda{|s, o| o[:entity_options]["school"][:fill_rate]}
    end
  end
end

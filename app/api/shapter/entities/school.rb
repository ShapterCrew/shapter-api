module Shapter
  module Entities
    class School < Grape::Entity
      expose :pretty_id, as: :id
      expose :best_comments, if: lambda{|u,o| o[:entity_options]["school"][:best_comments]}, using: Shapter::Entities::Comment do |school,ops|
        school.best_comments(ops[:entity_options]["school"][:best_comments_count] || 5)
      end

      expose :students_count, if: lambda{|s, o| o[:entity_options]["school"][:students_count]}
      expose :comments_count, if: lambda{|s, o| o[:entity_options]["school"][:comments_count]}
      expose :diagrams_count, if: lambda{|s, o| o[:entity_options]["school"][:diagrams_count]}
      expose :img_url       , if: lambda{|s, o| o[:entity_options]["school"][:img_url]}
      expose :fill_rate     , if: lambda{|s, o| o[:entity_options]["school"][:fill_rate]}
      expose :name      , if: lambda{ |u,o| o[:entity_options]["school"][:name]}
      expose :short_name, if: lambda{ |u,o| o[:entity_options]["school"][:short_name]}

      expose :website_url, if: lambda{ |u,o| o[:entity_options]["school"][:website_url]}
      expose :description, if: lambda{ |u,o| o[:entity_options]["school"][:description]}
    end
  end
end

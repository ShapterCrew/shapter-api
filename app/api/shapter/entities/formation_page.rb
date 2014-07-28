module Shapter
  module Entities
    class FormationPage < Grape::Entity
      expose :pretty_id, as: :id
      expose :best_comments, using: Shapter::Entities::Comment, if: lambda{|u,o| o[:entity_options]["formation_page"][:best_comments]} do |formation_page,ops|
        formation_page.best_comments(ops[:entity_options]["formation_page"][:best_comments_count] || 5)
      end

      expose :students_count , if: lambda{|_,o| o[:entity_options]["formation_page"][:students_count]}
      expose :comments_count , if: lambda{|_,o| o[:entity_options]["formation_page"][:comments_count]}
      expose :diagrams_count , if: lambda{|_,o| o[:entity_options]["formation_page"][:diagrams_count]}
      expose :img_url        , if: lambda{|_,o| o[:entity_options]["formation_page"][:img_url]}
      #expose :fill_rate      , if: lambda{|_,o| o[:entity_options]["formation_page"][:fill_rate]}
      expose :name           , if: lambda{|_,o| o[:entity_options]["formation_page"][:name]}
      #expose :short_name     , if: lambda{|_,o| o[:entity_options]["formation_page"][:short_name]}

      expose :website_url    , if: lambda{|_,o| o[:entity_options]["formation_page"][:website_url]}
      expose :description    , if: lambda{|_,o| o[:entity_options]["formation_page"][:description]}
      expose :sub_formations , if: lambda{|_,o| o[:entity_options]["formation_page"][:sub_formations]}
    end
  end
end


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
      expose :name           , if: lambda{|_,o| o[:entity_options]["formation_page"][:name]}

      expose :logo_url       , if: lambda{|_,o| o[:entity_options]["formation_page"][:logo]}
      expose :image_url      , if: lambda{|_,o| o[:entity_options]["formation_page"][:image]}

      expose :website_url    , if: lambda{|_,o| o[:entity_options]["formation_page"][:website_url]}
      expose :description    , if: lambda{|_,o| o[:entity_options]["formation_page"][:description]}
      expose :sub_formations , using: Shapter::Entities::Tag, if: lambda{|_,o| o[:entity_options]["formation_page"][:sub_formations]}
      expose :sub_choices , using: Shapter::Entities::Tag, if: lambda{|_,o| o[:entity_options]["formation_page"][:sub_choices]}
      expose :sub_departments , using: Shapter::Entities::Tag, if: lambda{|_,o| o[:entity_options]["formation_page"][:sub_departments]}
    end
  end
end


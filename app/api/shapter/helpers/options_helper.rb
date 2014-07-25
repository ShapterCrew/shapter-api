module Shapter
  module Helpers
    module OptionsHelper

      def entity_options
        empty_h = {
          "comment"           => {},
          "course_builder"    => {},
          "diagram"           => {},
          "item"              => {},
          "shared_doc"        => {},
          "signup_permission" => {},
          "tag"               => {},
          "user"              => {},
          "school"            => {},
          "category"          => {},
        }

        empty_h
        .merge(params[:entities] || {})
        .merge({:current_user => current_user})
      end

    end
  end
end

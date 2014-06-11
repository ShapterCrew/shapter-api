module Shapter
  module Entities
    class ItemId < Grape::Entity
      expose :name
      expose :pretty_id, as: :id

      expose :current_user_has_in_cart do |it,ops|
        it.user_has_in_cart?(ops[:current_user])
      end

      expose :current_user_has_in_constructor do |it,ops|
        it.user_has_in_constructor?(ops[:current_user])
      end

      expose :current_user_subscribed do |it,ops|
        it.user_subscribed?(ops[:current_user])
      end
      expose :tags, using: Shapter::Entities::Tag, if: {with_tags: true}
    end
  end
end




module Shapter
  module Helpers
    module UsersHelper

      #{{{ alike_users
      #users similar to the items you took
      def alike_users(user, max=10)
        a = Rails.cache.fetch("usrAlike|#{user.id}|#{timekey(user)}", expires_in: 3.hours) do
          items = db[:items].where("_id" => { "$in" => user.item_ids}).select(subscriber_ids: 1)

        items.reduce(Hash.new(0)) { |h,item|
          item["subscriber_ids"].each do |user_id|
            h[user_id] += 1.0/item["subscriber_ids"].size
          end
          h
        }.sort_by{|k,v| v}.reverse
        .map{|a| User.find(a.first)}
        .compact
        .reject{|u| u.id == user.id}
        end
        a.take(max)
      end
      #}}}

      #{{{ cart_alike_users
      #Users that have followed courses as you describe in your cart
      def cart_alike_users(user, max=10)
        a = Rails.cache.fetch("usrCartAlike|#{user.id}|#{timekey(user)}", expires_in: 3.hours) do
          items = db[:items].where("_id" => { "$in" => user.cart_item_ids}).select(subscriber_ids: 1)

        items.reduce(Hash.new(0)) { |h,item|
          item["subscriber_ids"].each do |user_id|
            h[user_id] += 1.0/item["subscriber_ids"].size
          end
          h
        }.sort_by{|k,v| v}.reverse
        .map{|a| User.find(a.first)}
        .compact
        .reject{|u| u.id == user.id}
        end
        a.take(max)
      end
      #}}}

      #{{{ items_reco
      # Recommandations based on the courses you took
      def items_reco(user,max=10)
        Item.find(
          alike_users(user,10).flat_map(&:item_ids).reject{|id| user.item_ids.include? id}.group_by{|id| id}.sort_by{|k,v| v.size}.reverse.map(&:first).take(max)
        )
      end
      #}}}

      #{{{ cart_items_reco
      # Recommandation based on your cart
      def cart_items_reco(user,max=10)
        Item.find(
          cart_alike_users(user,10).flat_map(&:item_ids).reject{|id| (user.cart_item_ids + user.item_ids).include? id}.group_by{|id| id}.sort_by{|k,v| v.size}.reverse.map(&:first).take(max)
        )
      end
      #}}}

      private

      def timekey(user)
        user.items.max(:updated_at).try(:utc).try(:to_s,:number)
      end

      def db
        @db ||= Mongoid::Sessions.default
      end

    end
  end
end

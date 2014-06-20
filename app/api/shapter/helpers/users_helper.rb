module Shapter
  module Helpers
    module UsersHelper

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

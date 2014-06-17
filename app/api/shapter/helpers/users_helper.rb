module Shapter
  module Helpers
    module UsersHelper

      def alike_users(user, max=5)
        a = Rails.cache.fetch("usrAlike|#{user.id}|#{user.updated_at.try(:utc).try(:to_s,:number)}", expires_in: 1.hours) do
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

      def db
        @db ||= Mongoid::Sessions.default
      end

    end
  end
end

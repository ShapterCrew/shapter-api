require 'ostruct'
module Shapter
  class Tags < Grape::API
    format :json

    helpers Shapter::Helpers::FilterHelper

    before do 
      check_user_login!
    end

    namespace :tags do 

      # index {{{
      desc "get all tags", { :notes => <<-NOTE
        Useful to build an exhaustive dictionnary of tags
        NOTE
      }
      get :/ do 
        present Tag.all, with: Shapter::Entities::Tag
      end
      #}}}

      # suggested {{{
      desc "suggested tags to filter with", { :notes => <<-NOTE
        Given a list of set tags, and given the user's tags, this route provides an array of relevant tags, associated with their weights.
        NOTE
      }
      params do 
        requires :selected_tags, type: Array, desc: "Array of tags"
        optional :ignore_user, type: Boolean, desc: "Ignore user's tags"
      end

      post :suggested do 

      ignore_user = params[:ignore_user]

        resp = { :recommended_tags => reco_tags(params[:selected_tags]) }
        .merge( ignore_user ? {} : { :user_tags => current_user.items.flat_map(&:tags).uniq })

        present OpenStruct.new(resp), with: Shapter::Entities::SuggestedTags 

      end
      # }}}

    end

  end

end

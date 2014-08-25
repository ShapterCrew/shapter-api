module Shapter
  module V7
    class FormationPages < Grape::API
      format :json

      before do 
        check_user_login!
      end

      namespace :formations do 

        #{{{ create/update
        desc "create or update formation informations"
        params do 
          requires :tag_ids, type: Array, desc: "a batch of tags that define the Formation scope"
          optional :name, type: String, desc: "name"
          optional :website_url, type: String, desc: "website url"
          optional :description, type: String, desc: "description"
          optional :logo, desc: "logo (file)"
          optional :image, desc: "image (file)"
        end
        post :create_or_update do
          check_user_admin!

          formation = FormationPage.find_by_tags(params[:tag_ids]) || FormationPage.new(tag_ids: params[:tag_ids])

          uploaded_logo = if params[:logo]
                            s = params[:logo].split(',').last
                            tempfile = Tempfile.new('logo')
                            tempfile.binmode
                            tempfile.write(Base64.decode64(s))
                            ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile)
                          end

          uploaded_image = if params[:image]
                             s = params[:image].split(',').last
                             tempfile = Tempfile.new('image')
                             tempfile.binmode
                             tempfile.write(Base64.decode64(s))
                             uploaded_image = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile)
                           end

          clean_p = [
            [:name , params[:name]],
            [:description , params[:description]],
            [:logo, uploaded_logo],
            [:image, uploaded_image],
            [:website_url, params[:website_url]],
          ].reduce({}) do |h,a|
            h.merge!( {a.first => a.last} ) if a.last
            h
          end

          if formation.update_attributes(clean_p)
            present formation, using: Shapter::Entities::FormationPage
          else
            error!(formation.error.messages)
          end

        end
        #}}}

        #{{{ get
        desc "get the formation page from a list of tags. If no record of FormationPage is found, then a new page is automatically generated"
        params do 
          requires :tag_ids, type: Array, desc: "a batch of tags that define the Formation scope"
        end
        post do 
          @formation_page = FormationPage.find_by_tags(params[:tag_ids]) || FormationPage.new(tag_ids: params[:tag_ids])
          tag_ids = params[:tag_ids].map{|id| BSON::ObjectId.from_string(id)}

          present @formation_page, with: Shapter::Entities::FormationPage, entity_options: entity_options
        end
        #}}}

        #{{{ typical users
        desc "get the profile of n typical users for this formation. If the 'randomize' flag is set to true, then a set of profiles will be randomly selected from the best candidates"
        params do 
          requires :tag_ids, type: Array, desc: "a batch of tags that define the Formation scope"
          optional :randomize, type: Boolean, desc: "randomize results", default: true
          optional :nb, type: Integer, desc: "number of expected results", default: 1
        end
        post :typical_users do 
          @formation_page = FormationPage.find_by_tags(params[:tag_ids]) || FormationPage.new(tag_ids: params[:tag_ids])
          nb = (params[:nb] || 1).to_i
          rand = !!params[:randomize]
          present :typical_users, @formation_page.typical_users(nb, rand), with: Shapter::Entities::User, entity_options: entity_options
        end
        #}}}

      end


    end

  end
end

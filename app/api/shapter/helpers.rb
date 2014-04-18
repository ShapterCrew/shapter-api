module Shapter
  module Helpers
    def pong
      :pong
    end

    def warden
      env['warden']
    end

    def user_signed_in?
      !!warden.user
    end

    def check_user_login!
      error!("please login" ,401) unless user_signed_in?
    end

    def current_user
      warden.user
    end

  end
end

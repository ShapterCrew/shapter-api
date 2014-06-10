require 'thor'

class Switcher < Thor
  desc "switch","switch fb credentials from <source_email> user account to <target_email> user account. Nothing won't be deleted"
  def switch(source_email,target_email)
    u1 = User.find_by(email: source_email) || raise("no user found with email #{source_email}")
    u2 = User.find_by(email: target_email) || raise("no user found with email #{target_email}")

    if u1.provider == "facebook"
      if u2.update_attributes(provider: u1.provider, uid: u1.uid, image: u1.image, facebook_email: u1.facebook_email) 
        u1.set(email: "deactivated_#{u1.email}")
        u1.unset(:provider, :uid, :image, :facebook_email)
        puts "success!"
      else
        raise u2.errors.messages
      end
    else
      puts "user #{source_email} has no facebook account. exiting"
      exit
    end

  end
end

Switcher.start(ARGV)

email = -> sess { User.find(Marshal.load(StringIO.new(sess.data.data))["warden.user.user.key"].first.first).email rescue nil }
valid = -> regex { -> sess { email.(sess) =~ regex} }

regex_email = /klatzmann/

MongoidStore::Session.desc(&:created_at).lazy.select(&valid.(regex_email)).each do |sess|
  puts "deleting session for email #{email.(sess)}"
  sess.destroy
end

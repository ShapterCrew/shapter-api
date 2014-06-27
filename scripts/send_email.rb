ses = AWS::SimpleEmailService.new

#users = User.lte(last_sign_in_at: Date.today - 7).lte(current_sign_in_at: Date.today - 7).lazy.select{|u| u.items.count > 0}.select{|u| u.comments.count < 5 }
users = User.where(provider: "facebook").where(email: /\Afake\./).where(schools: nil)
#users = User.any_in(email: ["tiberein@enst.fr","mail@aurelien-herve.com", "ulysseklatzmann@gmail.com"])

users.each do |u|
  ses.send_email(
    :subject => 'Un problème avec ton compte Facebook sur Shapter ?',
    :from => 'teamShapter@shapter.com',
    :to => u.facebook_email,
    :body_html => <<-EMAIL
    <div style="font-family:arial,sans-serif;font-size:13px">Salut à toi cher utilisateur de&nbsp;<a href="http://shapter.com/" target="_blank">Shapter</a>,</div>
    <div style="font-family:arial,sans-serif;font-size:13px"><br></div>
    <div style="font-family:arial,sans-serif;font-size:13px">Nous avons constaté que tu as tenté de te connecter avec Facebook sur Shapter ! Malheureusement, suite à un mauvais alignement entre Jupiter et Mercure, le login avec Facebook a récemment recontré quelques problèmes, et tu sembles y avoir été confronté puisque tu n'as pas lié ton compte Facebook à une adresse mail étudiante. Nous en sommes profondément désolés. Mais heureusement, ce temps est désormais révolu ! <b>Tu peux donc aller tout de suite sur <a href="http://shapter.com" target="_blank">shapter</a>&nbsp;te connecter avec Facebook</b> et profiter à la fois du login en un clic et des nombreuses fonctionnalités que cela t'apporte (que l'on multiplie de jour en jour tel Jésus multipliant les pains (au moins)) !</div>
    <div style="font-family:arial,sans-serif;font-size:13px"><br></div>
    <div style="font-family:arial,sans-serif;font-size:13px"><b>N'hésite pas à nous contacter</b> à <a href="mailto:teamshapter@gmail.com" target="_blank">teamshapter@gmail.com</a> si tu rencontres le moindre soucis.</div>
    <div style="font-family:arial,sans-serif;font-size:13px"><br></div>
    <div style="font-family:arial,sans-serif;font-size:13px">À très bientôt sur Shapter (<a href="http://shapter.com/" target="_blank">http://shapter.com</a>),</div>
    <div style="font-family:arial,sans-serif;font-size:13px"><br></div>
    <div style="font-family:arial,sans-serif;font-size:13px">PS: si tu veux savoir pourquoi on te fait chier avec les inscriptions compliquées (validation d'adresse mail étudiante), tu peux lire cet article écrit par nos soins :&nbsp;<a href="http://shaptercrew.github.io/blog/2014/06/13/linscription-par-un-email-decole/" target="_blank">http://shaptercrew.github.<wbr>io/blog/2014/06/13/<wbr>linscription-par-un-email-<wbr>decole/</a></div>
    <div style="font-family:arial,sans-serif;font-size:13px"><br></div>
    <div style="font-family:arial,sans-serif;font-size:13px">The Shapter Crew.</div>
    EMAIL
  )
  puts u.facebook_email
end

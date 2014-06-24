ses = AWS::SimpleEmailService.new

#users = User.any_in(email: ["tiberein@enst.fr","mail@aurelien-herve.com"])
users = User.lte(last_sign_in_at: Date.today - 7).lte(current_sign_in_at: Date.today - 7).lazy.select{|u| u.items.count > 0}.select{|u| u.comments.count < 5 }

users.each do |u|
  ses.send_email(
    :subject => 'On a besoin de toi sur Shapter !',
    :from => 'teamShapter@shapter.com',
    :to => u.email,
    :body_html => <<-EMAIL
    <p>Salut à toi #{u.firstname},</p>

    <p>Tu t'es inscrit sur <a href='http://shapter.com'>Shapter</a>, et ça déjà, c'est super #swag (et t'as même gagné un badge pour ça). En revanche, il te reste encore des cours à commenter et des diagrammes à ajouter (voire même des documents à uploader, soyons fous) pour vraiment être méga stylé (et devenir, qui sait, une licorne de l'espace..?).</p>

    <p>Du coup plus une seconde à perdre, va sur <a href='http://shapter.com'>Shapter</a>, gagne plein de points et de badges, et fais plaisir à d'autres étudiants du même coup !</p>

    <p>Voici le lien si tu n'as pas vu les petits mots en bleu : http://shapter.com </p>

    <p>A très vite !</p>

    <p>The Shapter Crew.</p>
    EMAIL
  )
  puts u.email
end

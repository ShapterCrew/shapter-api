ses = AWS::SimpleEmailService.new

liste = ["ulysse@shapter.com"]

liste.each do |email|
  ses.send_email(
    :subject => 'Wouhou, aws email !',
    :from => 'teamShapter@shapter.com',
    :to => email,
    #:body_text => 'Sample email text.', #mets en si tu veux
    :body_html => <<-EMAIL
      <h1>Sample Email</h1>'
      haha lol  je peux mettre des " et des ' sans avoir besoin d'échapper, alors je suis content.
    EMAIL
  )
end

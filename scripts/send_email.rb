ses = AWS::SimpleEmailService.new

liste = ["promo2015@eurecom.fr","promo2014@eurecom.fr","promo2013@eurecom.fr"]

liste.each do |email|
  ses.send_email(
    :subject => 'Eurecom needs you !',
    :from => 'teamShapter@shapter.com',
    :to => email,
    :body_html => <<-EMAIL
    Dear Eurecom students,<br />
    <br />
    You had the chance to spend a sunny year in the south, which may have looked like holidays. You had the chance to follow The best Europe security program, and a lot more cool things.<br />
    <br />
    So bet it ! We are not jealous, Paris rain is good for the skin. But what we'd like, is you to tell us exactly what your great classes (or not) where about, by posting comments on <a href="shapter.com">Shapter</a> ! Thanks to you, future generation of Eurecom students will choose classes that fit the best there profile, and won't end up in front of boring teachers.<br />
    <br />
    For those who don't know it yet, Shapter is an awesome web site, made by students, for students : Access to comments and a way more cool stuffs about your classes from former students !<br />
    <br />
    One last thing, the website is teacher free. So feel free to say whatever you want.<br />
    To create an account, you must use your email address  first_name.last_name@eurecom.fr. It was the only way we had to be sure no teacher could login.<br />
    <br />
    Thanks in advance, and see you soon on <a href="shapter.com">shapter.com</a><br />
    <br />
    The Shapter Team
    EMAIL
  )
  puts email
end

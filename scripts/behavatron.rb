# Will generate every behave.io tracked action from database. W00t !

Item.each do |item|
  puts item.name

  # comments, comment-likes
  item.comments.each do |comment|
    Behave.delay.track comment.author_id.to_s, "comment", item: item.pretty_id

    comment.likers.each do |liker|
      Behave.delay.track liker.pretty_id, "like", last_state: 0, comment_author: comment.author_id.to_s, comment: comment.pretty_id
      Behave.delay.track comment.author_id.to_s, "receive like"
    end

    comment.dislikers.each do |disliker|
      Behave.delay.track disliker.pretty_id, "dislike", last_state: 0, comment_author: comment.author_id.to_s, comment: comment.pretty_id
    end

  end

  # cart
  item.interested_users.each do |user|
    Behave.delay.track user.pretty_id, "add to cart", item: item.pretty_id
  end

  # subscribe
  item.subscribers.each do |user|
    Behave.delay.track user.pretty_id, "subscribe item", item: item.pretty_id
  end

  # constructor
  item.constructor_users.each do |user|
    Behave.delay.track user.pretty_id, "add to constructor", item: item.pretty_id
  end

  # edit diagram
  item.diagrams.each do |diagram|
    Behave.delay.track diagram.author_id.to_s, "edit a diagram", item: item.pretty_id
  end

end


User.each do |user|
  puts user.email

  # signup
  user.track_signup_if_valid_student!

  # login
  user.sign_in_count.times { user.track_login!}
end


class Item
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :tags, type: Array

  embeds_many :comments

  has_and_belongs_to_many :likers, class_name: "User", inverse_of: :liked_items
  has_and_belongs_to_many :dislikers, class_name: "User", inverse_of: :disliked_items

  has_and_belongs_to_many :tags

  has_and_belongs_to_many :subscribers, class_name: "User", inverse_of: :items

  def comments_count
    comments.count
  end

  def user_likes?(user)
    return 1 if likers.include?(user)
    return -1 if dislikers.include?(user)
    return 0
  end

  def avg_quality_score
    comments.avg(:quality_score)
  end

  def avg_work_score
    comments.avg(:work_score)
  end

  def pretty_id
    id.to_s
  end

end

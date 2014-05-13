class Item

  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description, type: String
  field :tags, type: Array

  embeds_many :comments

  has_and_belongs_to_many :tags

  has_and_belongs_to_many :subscribers, class_name: "User", inverse_of: :items

  class << self
    def touch
      Item.find_or_create_by(name: "__null__").touch
    end
  end

  after_destroy :class_touch
  def class_touch
    Item.touch
  end

  def comments_count
    comments.count
  end

  def subscribers_count
    subscribers.count
  end

  def avg_quality_score
    comments.where(:quality_score.exists => true).avg(:quality_score)
  end

  def avg_work_score
    comments.where(:work_score.exists => true).avg(:work_score)
  end

  def pretty_id
    id.to_s
  end

  def remove_tag!(tag)
    tags.delete(tag)
    tag.destroy if tag.items.empty?
    self.save
  end

  def user_subscribed?(user)
    raise "wrong parameter" unless user.is_a? User
    subscribers.include? user
  end

  def user_comments_count(user)
    raise "wrong parameter" unless user.is_a? User
    comments.where(author: user).count
  end

end

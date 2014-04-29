class Comment
  include Mongoid::Document
  field :content, type: String
  field :work_score, type: Integer
  field :quality_score, type: Integer

  embedded_in :item
  belongs_to :author, class_name: "User"

  has_and_belongs_to_many :likers, class_name: "User", inverse_of: :liked_comments
  has_and_belongs_to_many :dislikers, class_name: "User", inverse_of: :disliked_comments

  validates_presence_of :author
  validates_presence_of :content
  validates_presence_of :work_score
  validates_presence_of :quality_score

  [:work_score, :quality_score].each do |p|
    validates_numericality_of p, {greater_than_or_equal_to: 1}
    validates_numericality_of p, {less_than_or_equal_to: 100}
    validates_numericality_of p, {only_integer: true}
  end

  def pretty_id
    id.to_s
  end

  def item_id
    item.id.to_s
  end

  def likers_count
    likers.count
  end

  def dislikers_count
    dislikers.count
  end

  def user_likes?(user)
    return 1 if likers.include?(user)
    return -1 if dislikers.include?(user)
    return 0
  end

end

class Item

  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description, type: String
  field :tags, type: Array
  field :requires_comment_score, type: Integer

  embeds_many :comments
  embeds_many :diagrams

  has_and_belongs_to_many :tags

  has_and_belongs_to_many :subscribers, class_name: "User", inverse_of: :items
  has_and_belongs_to_many :interested_users, class_name: "User", inverse_of: :cart_items
  has_and_belongs_to_many :constructor_users, class_name: "User", inverse_of: :constructor_users

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
    Rails.cache.fetch("itSubsCnt|#{self.id}|#{updated_at.try(:utc).try(:to_s, :number)}", :expires_in => 1.hours) do 
      subscribers.count
    end
  end

  def interested_users_count
    Rails.cache.fetch("itIntUsersCnt|#{self.id}|#{updated_at.try(:utc).try(:to_s, :number)}", :expires_in => 1.hours) do 
      interested_users.count
    end
  end

  def pretty_id
    id.to_s
  end

  def remove_tag!(tag)
    tags.delete(tag)
    self.save
    tag.reload
    tag.destroy if tag.items.empty?
  end

  def user_subscribed?(user)
    raise "wrong parameter" unless user.is_a? User
    subscribers.include? user
  end

  def user_has_in_cart?(user)
    raise "wrong parameter" unless user.is_a? User
    interested_users.include? user
  end

  def user_has_in_constructor?(user)
    raise "wrong parameter" unless user.is_a? User
    constructor_users.include? user
  end

  def user_comments_count(user)
    raise "wrong parameter" unless user.is_a? User
    comments.where(author: user).count
  end

  def user_can_view_comments?(user)
    raise "wrong parameter" unless user.is_a? User
    ok_school = !(tags & user.schools).empty?
    ok_admin = user.shapter_admin
    ok_admin or ok_school
  end

  def raw_avg_diag
    @raw_avg_diag ||= (
      d =   if diagrams.empty?
              Diagram.new_empty
            else
              (diagrams.reduce(:+) / diagrams.map(&:count_els).reduce(:+))
            end
    )
  end

  def avg_diag
    @avg_diag ||= (
    d = raw_avg_diag.fill_with(50)
    d.item = self
    d
    )
  end

  def diagrams_count
    diagrams.count
  end

  def user_diagram(user)
    if d = diagrams.find_by(author: user)
      d
    else
      d = Diagram.new_empty
      d.author = user
      d.item = self
      d
    end
  end

  def front_avg_diag
    Rails.cache.fetch("frontAvgDiag|#{self.id.to_s}|#{diag_timestamp_key}", expires_in: 90.minutes) do 
      avg_diag.front_values if avg_diag
    end
  end

  before_save :set_requires_comment_score

  private

  def set_requires_comment_score
    self.requires_comment_score = ( 10*interested_users_count - subscribers_count - 20*comments_count)
  end

  def diag_timestamp_key
    Item.find(id).diagrams.max(:updated_at).try(:utc).try(:to_s, :number)
  end

end

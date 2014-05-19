class Item

  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description, type: String
  field :tags, type: Array

  embeds_many :comments
  embeds_many :diagrams

  has_and_belongs_to_many :tags

  has_and_belongs_to_many :subscribers, class_name: "User", inverse_of: :items
  has_and_belongs_to_many :interested_users, class_name: "User", inverse_of: :cart_items

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

  def avg_diag
    #must memoize, otherwise the averaged diagram itself is considered as a user diagram
    @avg_diag ||= (
      c = diagrams.count
      if c > 0
        d =  diagrams.reduce(:+)
        d.values = d.values.map{|v| v.to_f/c}
      else
        d = Diagram.new_empty
      end
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
    self.reload
    Rails.cache.fetch("frontAvgDiag|#{self.id.to_s}|#{diagrams.max(:updated_at).try(:utc).try(:to_s, :number)}", expires_in: 90.minutes) do 
      avg_diag.front_values if avg_diag
    end
  end

end

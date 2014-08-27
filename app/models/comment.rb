class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, type: String
  field :context, type: String

  embedded_in :item
  belongs_to :author, class_name: "User"

  has_and_belongs_to_many :likers, class_name: "User", inverse_of: :liked_comments
  has_and_belongs_to_many :dislikers, class_name: "User", inverse_of: :disliked_comments

  validates_presence_of :author
  validates_presence_of :content

  def unescaped_content
    CGI.unescapeHTML(content)
  end

  def unescaped_context
    CGI.unescapeHTML(context || "")
  end

  # If asking_user is a facebook friend, or a student from same school, then the comment can be viewed. Otherwise, it is hidden.
  def public_content(asking_user,force=false)
    pc = if force or user_can_view?(asking_user)
           unescaped_content
         else
           "hidden"
         end
  end

  def pretty_id
    id.to_s
  end

  def item_id
    item.id.to_s
  end

  def item_name
    item.name
  end

  def likers_count
    Rails.cache.fetch("likersCnt|#{item.id}|#{self.id}|#{self.timestamp_key}",expires_in: 1.hours) do 
      likers.count
    end
  end

  def dislikers_count
    Rails.cache.fetch("dislikersCnt|#{item.id}|#{self.id}|#{self.timestamp_key}",expires_in: 1.hours) do 
      dislikers.count
    end
  end

  def user_likes?(user)
    return 1 if likers.include?(user)
    return -1 if dislikers.include?(user)
    return 0
  end

  def timestamp_key
    updated_at.try(:utc).try(:to_s, :number)
  end

  before_save :touches
  validate :context_validator
  validates_length_of :context, maximum: 70

  def touches
    self.touch
    item.touch
    author.touch
  end

  def context_validator
    errors.add(:context, "a context is required for alien comments") if (alien? and context.blank?)
  end

  def user_can_view?(user)
    prom_buddy(user) or fb_buddy(user) or his_campus(user)
  end

  # An alien is someone who comments a course without being a verified student of the campus
  def alien?
    (author.school_ids & item.tag_ids).empty?
  end

  def alien_schools
    author.schools - item.tags
  end

  private

  def prom_buddy(user)
    (user.school_ids & author.school_ids).any?
  end

  def fb_buddy(user)
    user.is_friend_with?(author) 
  end

  def his_campus(user)
    (item.tag_ids & user.school_ids).any? 
  end

end

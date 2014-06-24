class Item
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  field :short_name, type: String
  field :requires_comment_score, type: Integer

  embeds_many :comments
  embeds_many :diagrams
  embeds_many :shared_docs

  has_and_belongs_to_many :tags

  has_and_belongs_to_many :subscribers, class_name: "User", inverse_of: :items
  has_and_belongs_to_many :interested_users, class_name: "User", inverse_of: :cart_items
  has_and_belongs_to_many :constructor_users, class_name: "User", inverse_of: :constructor_users

  class << self
    def touch
      Item.find_or_create_by(name: "__null__").touch
    end

    # {{{ merge item t2 into item t1. Tag t2 will be destroyed
    # item2 relations will be added to item1. 
    # item1 attributes take priority over item2 attributes (name, description...etc)
    def merge!(item1,item2)

      new_attr = {
        :name                 => item1.name.blank?        ? item2.name        : item1.name,
        :description          => item1.description.blank? ? item2.description : item1.description,
        :short_name           => item1.short_name.blank?  ? item2.short_name  : item1.short_name,
        :tag_ids              => [item1,item2].map(&:tag_ids).reduce(:+).uniq,
        :subscriber_ids       => [item1,item2].map(&:subscriber_ids).reduce(:+).uniq,
        :interested_user_ids  => [item1,item2].map(&:interested_user_ids).reduce(:+).uniq,
        :constructor_user_ids => [item1,item2].map(&:constructor_user_ids).reduce(:+).uniq,
      }

      if item1.update_attributes(new_attr)
        item1.touch
        [:comments, :diagrams, :shared_docs].each do |key|
          item2.send(key).each do |stuff|
            ss = stuff.dup
            ss.item = item1
            puts ss.errors.messages unless ss.save
          end
        end
        item2.destroy
        return true
      else
        puts item1.errors.messages
        return false
      end

    end
    #}}}

  end

  before_destroy :custom_destroy_callbacks
  after_destroy :class_touch
  def class_touch
    Item.touch
  end

  def comments_count
    comments.count
  end

  def documents_count
    shared_docs.count
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

  def user_has_diagram?(user)
    diagrams.where(author: user).exists?
  end

  def user_has_comment?(user)
    comments.where(author: user).exists?
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

  def custom_destroy_callbacks

    tags.each do |tag|
      tag.update_attribute(:item_ids, tag.item_ids - [self.id])
    end

    subscribers.each do |sub|
      sub.update_attribute(:item_ids, sub.item_ids - [self.id])
    end

    interested_users.each do |sub|
      sub.update_attribute(:cart_item_ids, sub.cart_item_ids - [self.id])
    end

    constructor_users.each do |sub|
      sub.update_attribute(:constructor_user_ids, sub.constructor_user_ids - [self.id])
    end
  end

  def set_requires_comment_score
    self.requires_comment_score = ( 10*interested_users_count - subscribers_count - 20*comments_count)
  end

  def diag_timestamp_key
    Item.find(id).diagrams.max(:updated_at).try(:utc).try(:to_s, :number)
  end

end

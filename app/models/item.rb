class Item
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :tags, type: Array

  embeds_many :comments

  has_and_belongs_to_many :tags

  has_and_belongs_to_many :subscribers, class_name: "User", inverse_of: :items

  has_and_belongs_to_many :students, class_name: "User", inverse_of: :schools

  def comments_count
    comments.count
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

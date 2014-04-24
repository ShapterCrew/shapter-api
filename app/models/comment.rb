class Comment
  include Mongoid::Document
  field :content, type: String
  field :work_score, type: Integer
  field :quality_score, type: Integer

  embedded_in :item
  belongs_to :author, class_name: "User"

  validates_presence_of :author
  validates_presence_of :content
  validates_presence_of :work_score
  validates_presence_of :quality_score

  [:work_score, :quality_score].each do |p|
    validates_numericality_of p, {greater_than_or_equal_to: 1}
    validates_numericality_of p, {less_than_or_equal_to: 100}
    validates_numericality_of p, {only_integer: true}
  end


end

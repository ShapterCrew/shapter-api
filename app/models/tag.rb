class Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  validates_uniqueness_of :name

  # Don't forget to update Tag.merge when adding new relations
  has_and_belongs_to_many :items
  has_and_belongs_to_many :students, class_name: "User", inverse_of: :schools

  def pretty_id
    id.to_s
  end

  class << self
    def touch
      Tag.find_or_create_by(name: "__null__").touch
    end

    def merge!(t1,t2)
      t2.items.each{|i| t1.items << i}
      t2.students.each{|s| t1.students << s}
      if t1.save
        t2.destroy
        true
      else
        false
      end
    end

  end

  after_destroy :class_touch
  def class_touch
    Tag.touch
  end
end

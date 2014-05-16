class Diagram
  include Mongoid::Document

  field :values, type: Array

  embedded_in :item
  belongs_to :author, class_name: "User"

  validates_presence_of :author

  def names
    [
      "maths",
      "ecl_dim",
      "telecom_dim",
      "pipo",
    ]
  end

  def front_values
    front_dims.map{|i|
      {
        i => {
        :value => values[i],
        :name => names[i],
      }
      }
    }.reduce(&:merge)
  end

  def + diag
    Diagram.new(
      values: self.values.zip(diag.values)
      .map{|a| (a.first || a.last) ? (a.first || 0) + (a.last || 0) : nil}
    )
  end

  def pretty_id
    id.to_s
  end

  class << self

    def new_empty
      Diagram.new(values: (1..Diagram.values_size).map{|i| nil})
    end

    def values_size
      4
    end

    def centrale_lyon_dimensions
      [0,1,3]
    end

    def telecom_paristech_dimensions
      [0,2,3]
    end

  end

  private

  def front_dims
    s = []
    s += Diagram.centrale_lyon_dimensions if item.tags.where(name: "Centrale Lyon").exists?
    s += Diagram.telecom_paristech_dimensions if item.tags.where(name: "Telecom ParisTech").exists?
    s.uniq
  end

end

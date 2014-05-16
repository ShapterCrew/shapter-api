class Diagram
  include Mongoid::Document

  field :values, type: Array

  embedded_in :item
  belongs_to :author, class_name: "User"

  validates_presence_of :author

  def names
    [
      "quality",
      "work_load",
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
      6
    end

    def centrale_lyon_dimensions
      [2,3,5]
    end

    def telecom_paristech_dimensions
      [2,4,5]
    end

  end

  private

  def front_dims
    s = [0,1]
    s += Diagram.centrale_lyon_dimensions if item.tags.where(name: "Centrale Lyon").exists?
    s += Diagram.telecom_paristech_dimensions if item.tags.where(name: "Telecom ParisTech").exists?
    s.uniq
  end

end

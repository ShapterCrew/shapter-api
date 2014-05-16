class Diagram
  include Mongoid::Document

  MAX_DIM = 4 # total number of dimensions

  (0..MAX_DIM - 1).each do |i|
    field "x#{i}", type: Integer
  end

  embedded_in :item
  belongs_to :author, class_name: "User"

  validates_presence_of :author

  def x0_name
    "maths"
  end

  def x1_name
    "ecl_dim"
  end

  def x2_name
    "telecom_dim"
  end

  def x3_name
    "pipo"
  end

  def values
    front_dims.map{|i|
      {
        "x#{i}" => {
        :value => self.send("x#{i}"),
        :name => self.send("x#{i}_name"),
      }
      }
    }.reduce(&:merge)
  end

  def + diag
    Diagram.new(
      (0..MAX_DIM - 1).map { |i|
      if self.send("x#{i}") or diag.send("x#{i}") 
        ["x#{i}" , (self.send("x#{i}") || 0 ) + (diag.send("x#{i}") || 0 )]
      end
    }.compact.to_h
    )
  end

  class << self

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

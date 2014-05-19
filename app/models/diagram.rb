class Diagram
  include Mongoid::Document

  field :values, type: Array

  embedded_in :item
  belongs_to :author, class_name: "User"

  validates_presence_of :author

  def names
    Diagram.names
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
      names.size
    end

    def names
      [
        "Charge de travail", #00
        "Travail en groupe", #01
        "Maths"            , #02
        "Codage"           , #03
        "Théorique"        , #04
        "Technique"        , #05
        "Qualité"          , #06
        "Dur à valider"    , #07
        "Fun"              , #08
        "Pipo"             , #09
      ]
    end

    def centrale_lyon_dimensions
      [1,5,8,9]
    end

    def telecom_paristech_dimensions
      [1,2,3,4,8,9]
    end

    def supelec_dimensions
      [1,5,8,9]
    end

    def eurecom_dimensions
      [1,2,3,4,8,9]
    end

    def base_dimensions
      [0,6,7]
    end

  end

  private

  def front_dims
    s  = Diagram.base_dimensions
    s += Diagram.centrale_lyon_dimensions if item.tags.where(name: "Centrale Lyon").exists?
    s += Diagram.telecom_paristech_dimensions if item.tags.where(name: "Telecom ParisTech").exists?
    s += Diagram.supelec_dimensions if item.tags.where(name: "Supélec").exists?
    s += Diagram.eurecom_dimensions if item.tags.where(name: "Eurecom").exists?
    s.uniq
  end

end

class Diagram
  include Mongoid::Document
  include Mongoid::Timestamps

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

  def count_els
    Diagram.new( values: self.values.map{|v| v.nil? ? 0 : 1})
  end

  def / diag
    Diagram.new(
      values: self.values.zip(diag.values)
      .map{|a| a.last.to_i == 0 ? nil : a.first.to_f/a.last }
    )
  end

  def fill_with(n)
    Diagram.new(
      values: self.values.map{|v| v.nil? ? n : v}
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
        "Pipeau"           , #09
        "Économie"         , #10
      ]
    end

    def centrale_lyon_dimensions
      [1,5,8,9]
    end

    def telecom_paristech_dimensions
      [1,2,3,4,8,9]
    end

    def iren_dimensions
      [1,4,8,9,5,10]
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

  after_save :touches
  def touches
    self.touch
    item.touch
  end

  private

  def front_dims
    s  = Diagram.base_dimensions
    return s unless item
    s += Diagram.centrale_lyon_dimensions     if item.tags.where(name: /\A(Echange |)Centrale Lyon\z/).exists?
    s += Diagram.telecom_paristech_dimensions if item.tags.any_in(name: ["Telecom ParisTech","Master Vision et Apprentissage", "Master Parisien de recherche en informatique","Conception & Management des Systèmes Informatiques Complexes","Master Laure Elie"]).exists?
    s += Diagram.iren_dimensions              if item.tags.where(name: "Master Industries de Réseau et Économie Numérique").exists?
    s += Diagram.supelec_dimensions           if item.tags.where(name: /\A(Echange |)Supélec\z/).exists?
    s += Diagram.eurecom_dimensions           if item.tags.where(name: /\A(Echange |)Eurecom\z/).exists?
    s.uniq
  end

end

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
        "Charge de travail"         , #00
        "Travail en groupe"         , #01
        "Maths"                     , #02
        "Codage"                    , #03
        "Théorique"                 , #04
        "Technique"                 , #05
        "Qualité"                   , #06
        "Dur à valider"             , #07
        "Fun"                       , #08
        "Pipeau"                    , #09
        "Économie"                  , #10
        "fondamental"               , #11
        "Accessibilité"             , #12
        "Calcul"                    , #13
        "Professionalisant"         , #14
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

    def mnt_dimensions
      [8,9,1,5]
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

    def info_ulm_dimensions
      [2,3,1,8,11,12]
    end

    def bio_ulm_dimensions
      [8,9,11,12]
    end

    def chimie_ulm_dimensions
      [2,5,8,9,11,12]
    end

    def physique_ulm_dimensions
      [2,8,9,11,12,13]
    end

    def ensae_dimensions
      [2,3,4,8,9,10]
    end

    def geographie_ulm_dimensions
      [1,4,8,9,12,14]
    end

    def maths_ulm_dimensions
      [8,9,12,13]
    end

    def science_co_ulm_dimensions
      [2,8,9,12]
    end

    def eco_ulm_dimensions
      [1,2,3,8,9,12]
    end

    def dss_ulm_dimensions
      [1,8,9,12]
    end

    def antiquite_ulm_dimensions
      [1,8,9,12]
    end
    
    def histoire_ulm_dimensions
      [1,8,9,12]
    end

    def geoscience_ulm_dimensions
      [1,8,9,12]
    end

    def philo_ulm_dimensions
      [1,8,9,12]
    end

    def langue_ulm_dimensions
      [8,9]
    end

    def espci_dimensions
      [4,8,9,11,13]
    end

    def ape_dimensions
      [1,2,8,9]
    end

    def master_chimie_dimensions
      [2,8,9,11]
    end

    def ppd_dimensions
      [1,2,3,8,9,14]
    end

    def master_maths_dimensions
      [1,8,9,13]
    end

    def master_logique_dimensions
      [1,8,9,13]
    end

    def escp_dimensions
      [1,2,4,8,9,14]
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
    s += Diagram.telecom_paristech_dimensions if item.tags.any_in(name: ["Telecom ParisTech","Master Vision et Apprentissage", "Master Parisien de recherche en informatique","Conception & Management des Systèmes Informatiques Complexes","Master Laure Elie","Athens","Ponts ParisTech"]).exists?
    s += Diagram.iren_dimensions              if item.tags.where(name: "Master Industries de Réseau et Économie Numérique").exists?
    s += Diagram.mnt_dimensions               if item.tags.where(name: "MNT").exists?
    s += Diagram.supelec_dimensions           if item.tags.where(name: /\A(Echange |)Supélec\z/).exists?
    s += Diagram.eurecom_dimensions           if item.tags.where(name: /\A(Echange |)Eurecom\z/).exists?
    s += Diagram.chimie_ulm_dimensions        if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département de Chimie").exists?)
    s += Diagram.physique_ulm_dimensions      if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département de Physique").exists?)
    s += Diagram.geographie_ulm_dimensions    if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département de Géographie").exists?)
    s += Diagram.maths_ulm_dimensions         if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département de mathématiques").exists?)
    s += Diagram.bio_ulm_dimensions           if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département de Biologie").exists?)
    s += Diagram.science_co_ulm_dimensions    if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département de Sciences Cognitives").exists?)
    s += Diagram.info_ulm_dimensions          if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département informatique").exists?)
    s += Diagram.dss_ulm_dimensions           if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département de Sciences Sociales (DSS)").exists?)
    s += Diagram.antiquite_ulm_dimensions     if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département Sciences de l'antiquité").exists?)
    s += Diagram.histoire_ulm_dimensions      if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département d'Histoire").exists?)
    s += Diagram.geoscience_ulm_dimensions    if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Déparement des Géosciences").exists?)
    s += Diagram.philo_ulm_dimensions         if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département de Philosophie").exists?)


    s += Diagram.eco_ulm_dimensions           if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département d'économie").exists?)
    s += Diagram.langue_ulm_dimensions        if ((item.tags.where(name: "ULM").exists?) and item.tags.where(name: "Département de langues vivantes").exists?)
    s += Diagram.ensae_dimensions             if item.tags.where(name: "ENSAE").exists?
    s += Diagram.espci_dimensions             if item.tags.where(name: "ESPCI").exists?
    
    s += Diagram.ape_dimensions               if item.tags.where(name: "Master Analyse et Politique Économiques").exists?
    s += Diagram.master_chimie_dimensions     if item.tags.where(name: "Master de Sciences et Technologies, Mention Chimie").exists?
    s += Diagram.ppd_dimensions               if item.tags.where(name: "Politiques Publiques et Développement").exists?
    s += Diagram.master_maths_dimensions      if item.tags.where(name: "Master de Mathématiques Fondamentales").exists?
    s += Diagram.master_logique_dimensions    if item.tags.where(name: "Master Logique Mathématique et Fondements de l'Informatique").exists?

    s += Diagram.escp_dimensions              if item.tags.where(name: "ESCP Europe").exists?

    s.uniq
  end

end

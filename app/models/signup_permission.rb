class SignupPermission
  include Mongoid::Document

  field :email, type: String

  field :school_names, type: Array

  field :firstname, type: String
  field :lastname, type: String

  validates_presence_of :school_names
  validates_presence_of :email

  validates_uniqueness_of :email

  def pretty_id
    id.to_s
  end
end

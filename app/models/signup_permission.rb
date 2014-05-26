class SignupPermission
  include Mongoid::Document
  field :school_name, type: String
  field :email, type: String

  field :firstname, type: String
  field :lastname, type: String

  validates_presence_of :school_name
  validates_presence_of :email

  validates_uniqueness_of :email

  def pretty_id
    id.to_s
  end
end

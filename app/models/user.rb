class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :firstname, type: String
  field :lastname,  type: String
  field :shapter_admin, type: Boolean

  has_and_belongs_to_many :liked_comments, class_name: "Item", inverse_of: :likers
  has_and_belongs_to_many :disliked_comments, class_name: "Item", inverse_of: :dislikers

  has_and_belongs_to_many :items, class_name: "Item", inverse_of: :subscribers
  has_and_belongs_to_many :cart_items, class_name: "Item", inverse_of: :interested_users

  has_and_belongs_to_many :schools, class_name: "Tag", inverse_of: :students

  # {{{ devise
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time
  #}}}

  def sign_in_json
    {
      id: id.to_s,
      email: email,
      first_name: firstname,
      last_name: lastname,
      schools: schools.map{|s| {id: s.id.to_s, name: s.name}},
      admin: shapter_admin,
      confirmed: confirmed?
    }.to_json
  end

  def pretty_id
    id.to_s
  end

  def valid_password?(pwd)
    begin
      super(pwd)
    rescue
      Pbkdf2PasswordHasher.check_password(pwd,self.encrypted_password)
    end
  end

  validate :valid_school?
  before_validation :set_school

  before_save :items_touch

  private

  def items_touch
    items.each(&:touch) 
  end

  def valid_school?
    errors.add(:base,"user must belong to at least one school") if self.schools.empty?
  end

  def set_school
    self.schools << Tag.find_or_create_by(name: "Centrale Lyon") if (email =~ /.*@ecl[0-9]+.ec-lyon.fr/ or email =~ /.*@auditeur.ec-lyon.fr/)
    self.schools << Tag.find_or_create_by(name: "Centrale Paris") if email =~ /.*@student.ecp.fr/
    self.schools << Tag.find_or_create_by(name: "HEC") if email =~ /.*@hec.edu/

    if perm = SignupPermission.find_by(email: self.email)
      self.schools << Tag.find_or_create_by(name: perm.school_name)
    end
  end

end

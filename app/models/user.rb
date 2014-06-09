class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :facebook_email, type: String
  field :firstname, type: String
  field :lastname,  type: String
  field :shapter_admin, type: Boolean
  field :image, type: String

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
  devise :omniauthable, :omniauth_providers => [:facebook]

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

  #{{{ facebook

  field :provider, type: String
  field :uid, type: String

  def self.find_for_facebook_oauth(auth)

    if user = User.find_by(email: auth.info.email, provider: nil)
      user.update_attribute(:uid, auth.uid)
      user.update_attribute(:provider, auth.provider)
      user.update_attribute(:facebook_email , auth.info.email)
      user
    else

      where(auth.slice(:provider, :uid)).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.facebook_email = auth.info.email
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.firstname = auth.info.first_name   # assuming the user model has a name
        user.lastname  = auth.info.last_name   # assuming the user model has a name
        user.image = auth.info.image # assuming the user model has an image
      end

    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  #}}}

  def sign_in_json
    {
      id: id.to_s,
      email: email,
      firstname: firstname,
      lastname: lastname,
      schools: schools.map{|s| {id: s.id.to_s, name: s.name}},
      admin: shapter_admin,
      confirmed: confirmed?,
      sign_in_count: sign_in_count,
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
  before_validation :set_schools!
  before_validation :set_names!

  before_save :items_touch
  before_save :comments_touch

  before_create :skip_confirmation_notification!
  after_create :send_confirmation_if_required
  after_create :track_signup_if_valid_student!

  def track_signup_if_valid_student!
    if confirmed_student?
      Behave.delay.identify self.id.to_s,
        email: self.email,
        firstname: self.firstname || "unknown",
        lastname: self.lastname || "unknown",
        name: [self.firstname, self.lastname].join(" ") || "unknown",
        schools: self.schools.map(&:name) || "unknown",
        provider: self.provider || "null"

      Behave.delay.track self.id.to_s, "signup"
    end
  end

  def send_confirmation_if_required
    #no need to confirm facebook users
    unless self.provider == "facebook"
      if self.class.schools_for(self.email).any?
        self.send_confirmation_instructions
      end
    end
  end

  def comments
    Rails.cache.fetch("userComms|#{id}|#{updated_at.try(:utc).try(:to_s, :number)}", expires_in: 3.hours) do 
      Item.where("comments.author_id" => self.id).flat_map{|i| i.comments.where(author: self)}
    end
  end

  def comments_likes_count
    comments.map(&:likers_count).reduce(:+)
  end

  def comments_dislikes_count
    comments.map(&:dislikers_count).reduce(:+)
  end

  def user_diagram
    Rails.cache.fetch("userDiag|#{id}|#{items.max(:updated_at).try(:utc).try(:to_s, :number)}", expires_in: 1.hours) do 
      unless (diags = items.map(&:raw_avg_diag) ).empty?
        d = (diags.reduce(:+) / diags.map(&:count_els).reduce(:+)).fill_with(50)
        d.item = items.first
      else
        d = Diagram.new_empty
      end
    d
    end
  end

  def confirmed_student?
    return true if ( provider == "facebook" and schools.any? and facebook_email == email) # signed up with facebook email, that matched a signup permission or regex
    return true if confirmed? and schools.any? # already confirmed an email, that gave a school
    false
  end

  def track_login!
    Behave.delay.track pretty_id, "login"
  end

  class << self
    def schools_for(email)
      schools = []
      schools << Tag.find_or_create_by(name: "Centrale Lyon") if (email =~ /.*@ecl[0-9]+.ec-lyon.fr/ or email =~ /.*@auditeur.ec-lyon.fr/)
      schools << Tag.find_or_create_by(name: "Centrale Paris") if email =~ /.*@student.ecp.fr/
        schools << Tag.find_or_create_by(name: "HEC") if email =~ /.*@hec.edu/

        if perm = SignupPermission.find_by(email: email)
          perm.school_names.each do |school_name|
            schools << Tag.find_or_create_by(name: school_name)
          end
        end
      return schools
    end
  end

  private

  def items_touch
    items.each(&:touch) 
  end

  def comments_touch
    liked_comments.each(&:touch)
    disliked_comments.each(&:touch)
  end

  def valid_school?
    unless self.provider == "facebook"
      errors.add(:base,"user must belong to at least one school") if self.schools.empty?
    end
  end

  def set_names!
    if perm = SignupPermission.find_by(email: self.email)
      self.firstname ||= perm.firstname if perm.firstname
      self.lastname  ||= perm.firstname if perm.lastname
    end
  end

  def set_schools!
    self.schools += self.class.schools_for(self.email)
  end


  def confirmation_required?
    false
  end


end

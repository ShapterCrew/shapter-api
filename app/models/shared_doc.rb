class SharedDoc
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description, type: String
  field :dl_count, type: Integer

  mount_uploader :file, FileUploader

  embedded_in :item

  has_and_belongs_to_many :likers, class_name: "User", inverse_of: :liked_documents
  has_and_belongs_to_many :dislikers, class_name: "User", inverse_of: :disliked_documents

  belongs_to :author, class_name: "User"

  validates_presence_of :name, :item
  validates_presence_of :author

  def pretty_id
    id.to_s
  end

  def file_url
    file.url
  end

  def public_file_url(who_asks)
    raise "#{who_asks} is no user" unless who_asks.is_a? User
    if item.user_can_comment?(who_asks)
      file_url
    else
      :hidden
    end
  end

  before_create :initialize_dl_count

  protected

  def initialize_dl_count
    self.dl_count ||= 0
  end

end

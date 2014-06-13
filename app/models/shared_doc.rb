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

  validates_presence_of :name, :file, :item
  validates_presence_of :author

  def pretty_id
    id.to_s
  end

  def file_url
    file.url
  end

  before_create :initialize_dl_count

  protected

  def initialize_dl_count
    self.dl_count ||= 0
  end

end

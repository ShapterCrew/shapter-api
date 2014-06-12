class SharedDoc
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description, type: String

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

end

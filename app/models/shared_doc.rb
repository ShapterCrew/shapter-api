class SharedDoc
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description, type: String
  #field :file, type: String

  mount_uploader :file, FileUploader

  belongs_to :item

  validates_presence_of :name, :file, :item

  def pretty_id
    id.to_s
  end

  def file_url
    file.url
  end

end

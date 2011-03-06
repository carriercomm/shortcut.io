class Url < ActiveRecord::Base

  acts_as_taggable_on :tags

  belongs_to    :account
  before_create :create_image_uuid
  after_create  :create_thumbnail

  validates_presence_of   :account_id
  validates_uniqueness_of :uri,         :scope => :account_id

  define_index do
    indexes uri
    indexes title
    indexes description

    has account_id

    set_property :delta => true
  end

  def generate_image_uuid
    if image_uuid.nil?
      update_attribute :image_uuid, UUID.generate
    end
  end

  private

  def create_image_uuid
    self.image_uuid = UUID.generate
  end

  def create_thumbnail
    Resque.enqueue( Thumbnail, self.uri, self.image_uuid )
  end
end

class Image < ApplicationRecord
  attr_accessor :image, :image_cache
  mount_uploader :image, ImageUploader
  process_in_background :image
  before_save :update_image_attributes
  belongs_to :item, polymorphic: true
  # validates_presence_of :image
  
  def update_image_attributes
    if image.present? && image_changed?
      if image.file.exists?
        self.image_content_type = image.file.content_type
        self.image_size = image.file.size
        self.image_width, self.image_height = `identify -format "%wx%h" #{image.file.path}`.split(/x/)
      end
    end
  end
  
end

class Comment < ApplicationRecord
  include PgSearch
  multisearchable :against => :content
  belongs_to :item, polymorphic: true, touch: true
  belongs_to :user
  mount_uploader :image, ImageUploader
  mount_uploader :attachment, AttachmentUploader
  validates_presence_of :user_id, :item_id, :item_type, :content
  before_save :update_image_attributes, :update_attachment_attributes
  after_create :update_activity_feed
  after_create -> {
    if item.class == Proposal
      ActiveRecord::Base.connection.execute "UPDATE proposals SET updated_at=now() WHERE id=#{item.id}"
    end
  }
  scope :frontpage, -> () { where(frontpage: true) }
  
  def update_activity_feed
    Activity.create(user: user, item: self.item, description: "commented on",  addition: 0)
    matches = content.scan(/rel=\"\/users\/(\d*)\"/)
    unless matches.empty?
      matches.flatten.each do |uu|
        u = User.find(uu.to_i)
        unless u.nil?
          Activity.create(user: u, description: 'was mentioned by', item: user, extra: self.item, extra_info: 'in a comment on ', addition: 0)
        end
      end
    end
  end
  
  def feed_date
    created_at
  end
  
  def title
    item.name
  end
  
  def body
    content_linked
  end
  
  def content_linked
    content.gsub(/href="(.*)#"/, '').gsub(/\srel="/, ' href="')
  end
  
  def update_image_attributes
    if image.present? && image_changed?
      if image.file.exists?
        self.image_content_type = image.file.content_type
        self.image_size = image.file.size
        self.image_width, self.image_height = `identify -format "%wx%h" #{image.file.path}`.split(/x/)
      end
    end
  end
  
  def update_attachment_attributes
    if attachment.present? && attachment_changed?
      if attachment.file.exists?
        self.attachment_content_type = attachment.file.content_type
        self.attachment_size = attachment.file.size
      end
    end
  end

  
end

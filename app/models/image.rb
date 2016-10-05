class Image < ActiveRecord::Base
	belongs_to :product

	has_attached_file :file,
		url: '/images/:id/:style/:basename.:extension',
	    path: ':rails_root/public/images/:id/:style/:basename.:extension',
	    default_url: '/assets/no_image.svg'
    validates_attachment_content_type :file, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
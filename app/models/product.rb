class Product < ActiveRecord::Base

	before_destroy :destroy_photo

	belongs_to :category

	has_attached_file :photo,
		url: '/products/:id/:style/:basename.:extension',
	    path: ':rails_root/public/products/:id/:style/:basename.:extension',
	    default_url: '/assets/no_image.svg'
    validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

    def photo_url
    	self.photo.url.split("?").first
    end

    def permalink
    	self.name_t	
    end

    def to_param
    	name_t
    end

	private
	
		def destroy_photo?
		   	self.photo.destroy if self.photo
		end
end
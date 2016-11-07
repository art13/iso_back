class Product < ActiveRecord::Base

	before_destroy :destroy_photo
	belongs_to :product_update
	belongs_to :category
	belongs_to :admin_user
	# has_many :ratings, dependent: :destroy
	# has_many :comments, dependent: :destroy
	has_many :images, dependent: :destroy
	has_attached_file :photo,
		url: '/products/:id/:style/:basename.:extension',
	    path: ':rails_root/public/products/:id/:style/:basename.:extension',
	    default_url: '/assets/no_image.svg'
    validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

    def photo_url
    	self.photo.url.split("?").first
    end

    def to_param
    	permalink
    end

    # def code
    # 	self.time_id
    # end

    def product_properties
    	self.properties
    end
	
	def product_categories
		categories = []
		category = self.category
		while category.parent_id > 0
			categories << {:name => category.name, :permalink => category.permalink}
			category = category.parent	
		end		
		categories << {:name => category.name, :permalink => category.permalink}
		categories.reverse
	end

	def rating
		rand(1.0..5.0).round(1)
	end

	def sample_products
		(self.category.products.to_a - [self]).first(8).pluck(:id)
	end

	def comments
		[{:autor => "A.Umnov", :comment =>"is simply dummy text of the printing and typesetting industry. 
										  Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, 
										  when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived"},
		{:autor => "I.Baranov", :comment => "t is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. 
										The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here'"},
		{:autor => "K.Brut", :comment => "here are many variations of passages of Lorem Ipsum available, 
										but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable"},
		{:autor => "L. Bikireva", :comment => "This book is a treatise on the theory of ethics, very popular during the Renaissance.
										The first line of Lorem Ipsum, 'Lorem ipsum dolor sit amet..', comes from a line in section 1.10.32."},
		{:autor => "S.Pliskin", :comment => "Contrary to popular belief, Lorem Ipsum is not simply random text. 
										It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock"}]
		
	end	

	def more_images
		[self.images.map{|i| i.file.url.split("?").first}]	
	end

	def self.search_by_props(values)	
		where("properties @>?", values.to_json)
	end

	def self.between_props(key, min, max)
		where("properties -> '#{key}' BETWEEN '#{min}' AND '#{max}' ")
	end

	def self.props_lt(key, max)
		where("properties -> '#{key}' < '#{max}' ")
	end

	def self.props_gt(key, min)
		where("properties -> '#{key}' > '#{min}' ")
	end

	def self.price_btw(min = 0, max = 1000000)
		min = 0 if min.nil?
		max = 1000000 if max.nil?
		where("price BETWEEN '#{min}' AND '#{max}' ")
	end

	private
		def destroy_photo
		   	self.photo.destroy if self.photo
		end
end
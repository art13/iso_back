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

    def to_param
    	permalink
    end

    def code
    	self.time_id
    end

    def product_properties
    	JSON.parse(self.properties)
    end
	
	def product_categories
		categories = []
		category = self.category
		until category.parent_id == 0
			categories << {:name => category.name, :permalink => category.permalink}
			category = category.parent	
		end		
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
	def description
		'<h3>1914 translation by H. Rackham</h3>
<p>"On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, 
so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish. In a free hour, when our power of choice is untrammelled and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains."</p>'
	end

	private
	
		def destroy_photo?
		   	self.photo.destroy if self.photo
		end
end
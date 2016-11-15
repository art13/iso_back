class Category < ActiveRecord::Base
	#acts_as_nested_set
	before_validation :get_position
	before_validation :generate_permalink
	belongs_to :parent, :class_name => "Category"
	before_validation :check_nil_parent
	has_many :children, :foreign_key => "parent_id", :class_name => "Category"
	has_many :products
	
	def product_name
    	"#{self.name} #{'(0)' if self.products.empty?}"	
    end
    
	private

	def generate_permalink
		# if params[:site_permalink]
		
		# else
			site_permalink = self.permalink.split("/").last
		  	cat = Category.find_by_permalink(site_permalink)
		  	if cat && cat.id != self.id
		    	n = 1
		    	while Category.find_by_permalink("#{site_permalink}-#{n}")
		     		n += 1
		    	end
		    	self.permalink = "#{site_permalink}-#{n}"
		  	else
		    	self.permalink = site_permalink
		  	end
		# end
	end

	def self.isolux
		scope = Category.where(:shop_id => 1)
	end

	def self.instr
		scope = Category.where(:shop_id => 2)
	end

	def self.get_parents
		where(:parent_id => nil)
	end

	def self.get_children(parent_id)
		where(:parent_id => parent_id)
	end

	def get_position
		self.position = 0 if self.position.nil?	
	end

	def check_nil_parent
		self.parent_id = nil if self.parent_id == 0 
	end

	def self.roots
		where("shop_id=? OR shop_id=?", 0, 1).where(:parent_id=> nil)
	end

	def is_final_category
		self.children.empty?	
	end
end
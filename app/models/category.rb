class Category < ActiveRecord::Base
	#acts_as_nested_set
	cattr_accessor :prod_props
	default_scope { order(position: :asc) }
	after_save :client_show
	# before_destroy :delete_from_products
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
	end
	
	def product_categories
		categories = []
		@categories = prod_props.to_a
		category = @categories.detect{|w| w.id == self.id}
		if category
			while !category.parent_id.nil? #|| category.parent_id > 0 
				categories << {:name => category.name, :permalink => category.permalink}
				category = @categories.detect{|w| w.id == category.parent_id}	
			end		
			categories << {:name => category.name, :permalink => category.permalink}
			categories.reverse
		else 
			[]
		end
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

	def self.root_all
		where(:parent_id=> nil)
	end

	def is_final_category
		self.children.empty?	
	end

	def client_show
		categories = Category.all.to_a
		results_ids = []
		@second_level = []
			parent = categories.detect{|w| w.id == self.id}
			@first_level = categories.select{|w| w.parent_id == parent.id}
			@first_level.each do |first_level_parent|
				@second_level += categories.select{|w| w.parent_id == first_level_parent.id}
			end 
			results_ids = @first_level.pluck(:id) + @second_level.pluck(:id)  
		Category.where(:id => results_ids).update_all(:show_on_front => self.show_on_front)
	end
end
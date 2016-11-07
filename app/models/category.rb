class Category < ActiveRecord::Base
	before_validation :generate_permalink

	belongs_to :parent, :class_name => "Category"
	has_many :children, :foreign_key => "parent_id", :class_name => "Category"
	has_many :products
	private
	
	def generate_permalink
		site_permalink = self.site_permalink.split("/").last
	  	if Category.where(:permalink => site_permalink).count > 0
	    	n = 1
	    	while Category.where(:permalink => "#{site_permalink}-#{n}").count > 0
	     		n += 1
	    	end
	    	self.permalink = "#{site_permalink}-#{n}"
	  	else
	    	self.permalink = site_permalink
	  	end
	end

	def self.isolux
		scope = Category.where(:shop_id => 1)
	end

	def self.instr
		scope = Category.where(:shop_id => 2)
	end

	def self.get_parents
		where(:parent_id => 0)
	end

	def self.get_children(parent_id)
		where(:parent_id => parent_id)
	end
end
class Category < ActiveRecord::Base
	before_validation :generate_permalink

	belongs_to :parent, :class_name => "Category"
	has_many :children, :foreign_key => "parent_id", :class_name => "Category"
	has_many :products
	private
	
	def generate_permalink
	  if Category.where(:permalink => self.site_permalink).count > 0
	    n = 1
	    while Category.where(:permalink => "#{self.site_permalink}-#{n}").count > 0
	      n += 1
	    end
	    self.permalink = "#{self.site_permalink}-#{n}"
	  else
	    self.permalink = self.site_permalink
	  end
	end
end
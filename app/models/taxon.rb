class Taxon < ActiveRecord::Base
	has_many :taxon_products
	before_validation :get_position
	before_validation :generate_permalink
	belongs_to :parent, :class_name => "Taxon"
	before_validation :check_nil_parent
	has_many :children, :foreign_key => "parent_id", :class_name => "Taxon"
	def product_name
    	"#{self.name} #{'(0)' if self.products.empty?}"	
    end
    
	private

	def generate_permalink
			site_permalink = self.permalink.split("/").last
		  	cat = Taxon.find_by_permalink(site_permalink)
		  	if cat && cat.id != self.id
		    	n = 1
		    	while Taxon.find_by_permalink("#{site_permalink}-#{n}")
		     		n += 1
		    	end
		    	self.permalink = "#{site_permalink}-#{n}"
		  	else
		    	self.permalink = site_permalink
		  	end
	end
	
	def product_categories
		categories = []
		@categories = Taxon.all.to_a
		taxon = @categories.detect{|w| w.id == self.id}
		if taxon
			while !taxon.parent_id.nil? #|| Taxon.parent_id > 0 
				categories << {:name => taxon.name, :permalink => taxon.permalink}
				taxon = @categories.detect{|w| w.id == taxon.parent_id}	
			end		
			categories << {:name => taxon.name, :permalink => taxon.permalink}
			categories.reverse
		else 
			[]
		end
	end

	def self.isolux
		scope = Taxon.where(:shop_id => 1)
	end

	def self.instr
		scope = Taxon.where(:shop_id => 2)
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
	
	def is_final_Taxon
		self.children.empty?	
	end
end
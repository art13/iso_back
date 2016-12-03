class Order < ActiveRecord::Base
	after_save :generate_code
	has_many :line_items, :dependent => :destroy
	accepts_nested_attributes_for :line_items
	belongs_to :customers

	def generate_code
		self.update_column(:code, self[:id].to_s.rjust(6, '0')) if self.code.nil?
	end
end
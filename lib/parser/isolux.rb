class Isolux < Parser
	attr_accessor :base_uri
	attr_accessor :limit

	def initialize
		@base_uri = "http://new.isolux.ru"
		@limit = 100
	end

	def build_uri(uri_array, page=nil)
		uri = "#{@base_uri}/#{uri_array.join('/')}.html?limit=#{@limit}"
		uri += page ? "&p=#{page}" : ""
		uri
	end
	
	# Get items links
	def get_max_page(uri_array)
		doc = open_uri build_uri(uri_array, 500)
		pg = doc.css('.isolux-pagination li a')
		pg.length===0 ? 1 : pg.last.inner_text.to_i
	end	
	
	# Get all links within current category
	def get_items_links(uri_arr)
		links = []
		(1..get_max_page(uri_arr) ).each do |x|
		    links.concat P.get_css_list P.build_uri(uri_arr), '.isolux-thumbnail-name a' 
		end
		
		links
	end
	
	# parse item
	def parse_item(uri)
		doc = open_uri(uri)
		
		doc = P.open_uri uri

		out = {}
		
		out[:name] = doc.css('.isolux-product-page-title h1 span').inner_text.strip
		out[:name_t] = uri.split("/")[3].split(".")[0].gsub("-"," ")
		
		picc = doc.css('.slickslider a')
		out[:pics] = picc.length===0 ? "" : picc[0]['href']
		raw_cat = doc.css('ol.isolux-breadcrumb li')[-2].inner_text.strip
		
		# Substitute category
		subc = P.rest_search('substs', raw_cat)

		unless subc.empty? then
			scat = subc.first['id']
		end 
		
		if scat.nil? then
			subc = P.rest_search('categories', raw_cat)
			
			if subc.empty?
				rxc = P.rest_add('categories', {:name => raw_cat})
				scat = rxc['id']
			else
				scat = subc.first['id']
			end
		end
		
		out[:category_id] = scat
		props = []
		
		doc.css('#tabmenu-attributes table tr').each do |x| 
		    o = {}
		    o['key'] = x.css('td')[0].inner_text.strip
		    o['val'] = x.css('td')[1].inner_text.strip
		
		    props.push o
		end
		
		out[:properties] = props.uniq.to_json
		out[:brand_id] = out[:properties]["Бренд"]
		out
	end
end
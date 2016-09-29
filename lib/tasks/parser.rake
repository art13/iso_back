#encoding: utf-8
task :parse_categories => :environment do 
	puts "start parsing"
	@heads = [{:name => "Стройматериалы", :permalink => 'stroymateriali.html'},
			{:name => "Отделочные материалы", :permalink => 'otdelochnie-materiali.html'},
			{:name => "Сантехника, отопление и водоснабжение", :permalink => 'santehnika.html'},
			{:name => "Электрика и освещение", :permalink => 'elektrotehnicheskoe-oborudovanie-1.html'},
			{:name => "Геоматериалы", :permalink => 'geomateriali.html'},
			{:name => "Инструмент и оборудование", :permalink => 'instrument-i-oborudovaniye.html'},
			{:name => "Дача и сад", :permalink => 'tovary-dlya-dachi-i-sada.html'}]
			
 	@base_uri  = "http://isolux.ru"
 	@limit = 100
 	@heads.each do |head|
 		puts "== start parse #{head[:name]} =="
 		@page = open_uri(@base_uri + "/" + head[:permalink])

 		@parent_category = Category.find_by_name(head[:name]) || 
 							Category.create(:name => head[:name], :permalink => clear_permalink(head[:permalink]), :time_id => time_id_generation(clear_permalink(head[:permalink]),""))
 		unless @parent_category.nil?
 			second_round = compile(@page, @parent_category)
 			puts "#{second_round}"
 			second_round.each do |second|
 				puts "#{second}"
 				if second[:name] != "Товары по акции"	
	 				second_category = Category.find_by_time_id(second[:time_id]) || Category.create(second)
	 				pager = @base_uri + "/" + clear_permalink(head[:permalink])+ "/" + second[:permalink] + ".html"
	 				puts "#{pager}"
	 				third_round = compile(open_uri(open(pager)), second_category)
	 				puts "third round"
	 				third_round.each do |round|
	 					Category.find_by_time_id(round[:time_id]) || Category.create(round)
	 				end
	 			end
 				puts "end of third round"
 			end
 			
 			puts "end of second round"
 		end
 		puts "== end =="
 	end
 	Category.where(:parent_id => 0).each do |parent|
 	#@categories_array = Category.where(:parent_id => 0).first.children.map{|c| [c.parent.permalink, c.permalink]}
 	# puts "#{@categories_array}"
 		@categories_array = parent.children.map{|c| [parent.permalink, c.permalink]}
 		parse_products(@categories_array)
 	end
end

def clear_permalink(permalink)
	permalink.split(".").first
end

def compile(page, parent)
	page.css(".categoryNavig ul li a").map{|a| {:permalink => clear_permalink(a['href'].split('/').last,), :name => a.text, :parent_id => parent.id, :time_id =>time_id_generation(clear_permalink(a['href'].split('/').last,), parent.permalink)}}
end

def parse_products(categories_array)
	links = []
	@products = []
	categories_array.each do |uri_arr|
	    print "Парсинг категории " + uri_arr.join("/") + "..."
	    itms = get_items_links(uri_arr)
	    puts "#{itms}"
	    links.concat itms
	    puts itms.length.to_s + ' товаров'
	end
	puts "Подготовлено к парсингу #{links.length} товаров."

	puts "Начало парсинга товаров"
	num = 0
	links.each do |link|
	    num += 1
	    print "Парсинг, #{num*100 / links.length} % завершено \r"
	    #@products << parse_item(link)
	    parse_item(link)
	end

	puts "Все товары добавлены в базу данных"
	puts "-- Парсинг завершён --"
end

def build_uri(uri_array, page=nil)
	@base_uri = "http://new.isolux.ru"
	uri = "#{@base_uri}/#{uri_array.join('/')}.html?limit=#{@limit}"
	uri += page ? "&p=#{page}" : ""
	uri
end

def get_max_page(uri_array)
	doc = open_uri build_uri(uri_array, 500)
	pg = doc.css('.isolux-pagination li a')
	pg.length===0 ? 1 : pg.last.inner_text.to_i
end	

def get_items_links(uri_arr)
	links = []
	(1..get_max_page(uri_arr) ).each do |x|
		links.concat get_css_list(build_uri(uri_arr), '.isolux-thumbnail-name a')
	end
	links
end

def get_css_list(uri, css_selector, attrib = "href")
	items = []
	open_uri(uri).css(css_selector).each{ |i| items.push i[attrib] }
	items
end

def get_css(uri, css_selector, index)
	open_uri(uri).css(css_selector)[index]
end

def open_uri(uri)
	Nokogiri::HTML(open(uri))
end

def time_id_generation(permalink, parent_permalink)
	Digest::MD5.hexdigest(parent_permalink + permalink)
end

def product_time_id(name)
	Digest::MD5.hexdigest(name)
end

def parse_item(uri)
		@products = []
		doc = open_uri(uri)
		out = {}
		
		out[:name] = doc.css('.isolux-product-page-title h1 span').inner_text.strip
		out[:name_t] = uri.split("/")[3].split(".")[0].gsub("-"," ")
		out[:time_id] = product_time_id(out[:name_t])
		
		picc = doc.css('.slickslider a')
		out[:pics] = picc.length==0 ? "" : picc[0]['href']
		raw_cat = doc.css('ol.isolux-breadcrumb li')[-2].inner_text.strip
		puts "------- #{raw_cat} ---------"
		# Substitute category
		# subc = rest_search('substs', raw_cat)

		# unless subc.empty? then
		# 	scat = subc.first['id']
		# end 
		
		# if scat.nil? then
		# 	subc = rest_search('categories', raw_cat)
			
		# 	if subc.empty?
		# 		rxc = rest_add('categories', {:name => raw_cat})
		# 		scat = rxc['id']
		# 	else
		# 		scat = subc.first['id']
		# 	end
		# end
		
		out[:category_id] = Category.first.id
		props = []
		
		doc.css('#tabmenu-attributes table tr').each do |x| 
		    o = {}
		    o['key'] = x.css('td')[0].inner_text.strip
		    o['val'] = x.css('td')[1].inner_text.strip
		
		    props.push o
		end
		
		out[:properties] = props.uniq.to_json
		#out[:brand_id] = out[:properties]["Бренд"]
		out
		puts "#{out}"
		Product.find_by_time_id(out[:time_id]) || Product.create(out)
end

def rest_get(zone, id=nil)
	Unirest.get(build_rest_uri(zone,id)).body
end
	
def rest_search(zone, term)
	xuri = build_rest_uri(zone) + "?search=#{term}"
	Unirest.get( URI.escape(xuri)).body
end

def build_rest_uri(zone, id=nil)
		uri = "#{@rest_uri}/#{zone}"
		uri += (id.nil?) ? "" : "/#{id}"
		uri += ".json"
		uri
end
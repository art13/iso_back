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
 							Category.create(:name => head[:name], :site_permalink => clear_permalink(head[:permalink]), :time_id => time_id_generation(clear_permalink(head[:permalink]),""))
 		unless @parent_category.nil?
 			second_round = compile(@page, @parent_category)
 			puts "#{second_round}"
 			second_round.each do |second|
 				puts "#{second}"
 				if second[:name] != "Товары по акции"	
	 				second_category = Category.find_by_time_id(second[:time_id]) || Category.create(second)
	 				pager = @base_uri + "/" + clear_permalink(head[:permalink])+ "/" + second[:site_permalink] + ".html"
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
 	#@categories_array = Category.where(:parent_id => 0).last.children.map{|c| [c.parent.site_permalink, c.site_permalink]}
 		@categories_array = parent.children.map{|c| [parent.permalink, c.permalink]}
 		puts "#{@categories_array}"
 		parse_products(@categories_array, parent.name)
 	end
end

def clear_permalink(permalink)
	permalink.split(".").first
end

def compile(page, parent)
	page.css(".categoryNavig ul li a").map{|a| {:site_permalink => clear_permalink(a['href'].split('/').last), :name => a.text, :parent_id => parent.id, :time_id =>time_id_generation(clear_permalink(a['href'].split('/').last,), parent.site_permalink)}}
end

def parse_products(categories_array, parent)
	links = []
	@products = []
	@categories = Category.all
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
	@new_products = []
	links.each do |link|
	    num += 1
	    print "Парсинг категории #{parent}, #{num*100 / links.length} % завершено \r"
	    #@products << parse_item(link)
	    parse_item(link, @categories, @new_products)
	end
	Product.create(@new_products)
	puts "товары  добавлены в базу данных"
	puts "-- Парсинг категории #{parent} завершён --"
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
	product_time_id(parent_permalink + permalink)
end

def product_time_id(name)
	Digest::MD5.hexdigest(name)
end

def parse_item(uri, categories, new_products)
		
		@update_products = []
		@products = []
		doc = open_uri(uri)
		out = {}
		
		out[:name] = doc.css('.isolux-product-page-title h1 span').inner_text.strip
		out[:permalink] = uri.split("/")[3].split(".")[0].gsub("-","_")
		out[:time_id] = product_time_id(out[:permalink])
		
		picc = doc.css('.slickslider a')
		out[:photo] = picc.length==0 ? "" : URI.parse(picc[0]['href'].split("?").first)
		category_tray = categories.find_by_time_id(get_category_id(doc))
		out[:category_id] = category_tray.nil? ? categories.find_by_time_id(get_category_id(doc, -3)).id : category_tray.id 

		props = []
		
		doc.css('#tabmenu-attributes table tr').each do |x| 
		    o = {}
		    o[:key] = x.css('td')[0].inner_text.strip
		    o[:val] = x.css('td')[1].inner_text.strip
		
		    props.push o
		end
		
		out[:properties] = props.uniq.to_json
		#out[:brand_id] = out[:properties]["Бренд"]
		out
		puts "#{out}"
		@current_product = Product.find_by_time_id(out[:time_id])
		puts "#{@current_product}" 
		@current_product.nil? ? new_products << out : @current_product.update_attributes(out)
		puts "#{new_products.size}"
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

def get_category_id(doc, step=-2)
	raw_cat = doc.css('ol.isolux-breadcrumb li')[step].css("a").attr("href").text
	puts "------- #{raw_cat} ---------"
	cat_link = raw_cat.split(".html").first.split("/").last(2).join
	puts cat_link
	product_time_id(cat_link)
end


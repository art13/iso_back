require 'nokogiri'
require 'unirest'
require 'open-uri'

class Parser
	attr_accessor :rest_uri
	
	def open_uri(uri)
		Nokogiri::HTML open uri
	end

	def get_css_list(uri, css_selector, attrib = "href")
		items = []
		open_uri(uri).css(css_selector).each{ |i| items.push i[attrib] }
		items
	end

	def get_css(uri, css_selector, index)
		open_uri(uri).css(css_selector)[index]
	end
	
	# -- Send Requests --
	def build_rest_uri(zone, id=nil)
		uri = "#{@rest_uri}/#{zone}"
		uri += (id.nil?) ? "" : "/#{id}"
		uri += ".json"
		uri
	end
	
	def rest_get(zone, id=nil)
		Unirest.get(build_rest_uri(zone,id)).body
	end
	
	def rest_search(zone, term)
		xuri = build_rest_uri(zone) + "?search=#{term}"
		Unirest.get( URI.escape(xuri)).body
	end
	
	def rest_add(zone, object, id=nil)
        puts '===='        
        puts object
        puts '===='
		#uri = build_rest_uri(zone, id)
		#if id.nil? then
			# Add new object
		#	response = Unirest.post uri, headers:{ "Accept" => "application/json" }, parameters: object
		#else
			# Update existing
		#	response = Unirest.put uri, headers:{ "Accept" => "application/json" }, parameters: object
		#end
		#response.body
	end
			
end

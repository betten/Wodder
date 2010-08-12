require 'rubygems'
require 'hpricot'
require 'open-uri'

class Gym
	
	attr_accessor :title, :href, :html, :saved_by_current_user

	def initialize(title,href)
		@title = title
		@href = href
		@html = nil
		@saved_by_current_user = false;
	end

	def clean_up_html
		@html.search("hr").remove
		remove_all_attr("style")
		remove_all_attr("align")
		remove_all_attr("id")
		remove_all_attr("color")
		# remove all classes except for class="more"
		@html.search("[@class]").each do |e|
			e.remove_attribute("class") unless e.attributes["class"].eql?("more")
		end
		convert_to_absolute("a","href")
		convert_to_absolute("img","src")
		@html.search("a").each do |e|
			e.raw_attributes["target"] = '_blank'
		end
		@html = Hpricot(@html.to_s.gsub(/(\n*<br\s*\/?>){2,}/i,'<br /><br />'))
	end

   private
	
	def convert_to_absolute(elem,attr)
		@html.search(elem).each do |e|
			uri = e.attributes[attr]
			if uri.match('^http').nil?
#				if uri.match('^\/').nil?
#					uri = '/' + uri
#				end
				u = URI.parse(@href)
				href = u + uri
				e.raw_attributes[attr] = href.to_s
			end
		end
	end

	def remove_all_attr(attr)
		@html.search("[@"+attr+"]").each do |e|
			e.remove_attribute(attr)
		end
	end

end

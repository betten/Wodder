require 'rubygems'
require 'hpricot'
require 'open-uri'

class Scrape

	def self.mainsite(gym)
		page = Hpricot(open(gym.href))
		gym.html = page.at("table[@width=440] div.blogbody")

                # separate 'more' section
                # img is wrapper in span and then in p
                # so first parent should be span, second parent should be p
                content = gym.html.at("p//img").parent.parent.previous_sibling
                more = content.following_siblings.remove
                more_html = '<div class="more">' + more.to_s + '</div>'
                content.after(more_html)
		return gym
	end

	def self.sealfit(gym)
		page = Hpricot(open(gym.href))
                gym.html = page.at("div.Post")

                # separate 'more' section
                content = gym.html.at('p[text()*="Notes"]')
		# found case in which p/notes does not have a previous sibling
		# in which case everything after notes is pushed to more
                if !content.previous_sibling.nil?
                        content = content.previous_sibling
                end
                more = content.following_siblings.remove
                # sealfit comments are in div id="CommentsForPost-1234"
                comments = gym.html.search('div[@id*="Comments"]').remove
                more_html = '<div class="more">' + more.to_s + comments.to_s + '</div>'
                content.after(more_html)
                # additional processing
                gym.html.search("img").remove
		return gym
	end

	def self.oneworld(gym)
                page = Hpricot(open(gym.href))

                title = page.at("h3.entry-header")
                post = title.at("a").attributes['href']

                body = page.at("div.entry-body")

		wod = Hpricot('')
		body.search("p[text()*='****']").each do |p|
			if p.next_sibling.inner_text.match(/workout|rest day/i)
				wod = Hpricot(p.following_siblings.to_s)
				wod.at("p[text()*='****']").following_siblings.remove unless wod.at("p[text()*='****']").nil?
				wod.search("p[text()*='****']").remove
				break
			end
		end

		# first find the workout section by either WORKOUT or REST text
#                before = page.at("p[text()*='****'] + p[text()*='WORKOUT']")
#                if before.nil?
#                        before = page.at("p[text()*='****'] + p[text()*='REST DAY']")
#                end
                # remove everything before
#                wod = before.following_siblings
                # remove everything after *'s, and then *'s
#                stars = body.at("p[text()*='****']")
#		stars.following_siblings.remove unless stars.nil? or stars.following_siblings.nil?
#                body.search("p[text()*='****']").remove

                # em doesn't look so great
                # this also removes strong, em > strong replaced with text
                wod.search("em").each do |e|
                        e.swap(e.inner_text)
                end

		# seems like everything is wrapped in strong
		wod.search("strong").each do |e|
			e.swap(e.inner_html)
		end
		# seems like the only things that should be strong are wrapped in spans
		wod.search("span").each do |e|
			e.swap('<strong>'+e.to_s+'</strong>')
		end

                more = Hpricot('<div class="more">WODs from Crossfit One World usually carry a lot of extra info.  You\'re best off just <a href="'+post.to_s+'">checking out the post</a> for more.</div>')

                gym.html = Hpricot::Elements[wod, more]
		return gym
	end

	def self.santacruz(gym)
		
		page = Hpricot(open(gym.href))
		
		# page is in parts
		# lets pull date, title, content, and more
		date = page.at("h2.date-header")
		entry = page.at("div.entry")
		title = entry.at("h3.entry-header")
		# more is listed first, text+img, followed by workout
		content = entry.at("div.entry-body")
		more = content.at("p[text()*='Workout']").preceding_siblings.remove
		#content = prev.following_siblings.remove
		content = Hpricot(content.to_s)
		# grab the footer
		footer = page.search("p.entry-footer-info").remove.first
		more = Hpricot('<div class="more">' + more.to_s + footer.to_s + '</div>')
		
		gym.html = Hpricot::Elements[title, date, content, more]
		return gym
	end

	def self.smash(gym)

		page = Hpricot(open(gym.href))
		gym.html = page.at("div.post")

		header = gym.html.search("//h3.entry-title").first
		content = gym.html.at("div.entry-content")

		img = gym.html.at("p//img")
		if img.nil?
			more = Hpricot('No more today!')
		else
			prev = img.parent.previous_sibling
			more = prev.following_siblings.remove
		end
		more = Hpricot('<div class="more">' + more.to_s + '</div>')

		gym.html = Hpricot::Elements[header, content, more]
		return gym
	end

	def self.football(gym)
		page = Hpricot(open(gym.href))
#		gym.html = page.at("div.Post")
	
		# separate 'more' section
		# split at p < a < img
#		img = gym.html.at("p//img")
#		if !img.nil?
#			content = img.parent.parent.previous_sibling
#			more = content.following_siblings.remove
#			more_html = '<div class="more">' + more.to_s + '</div>'
#		else 
#			content = gym.html.at("div[@id*='Comments']")
#			more_html = '<div class="more">No more!</div>'
#		end

#		content.after(more_html)

		content = page.at("div.Post")
		header = Hpricot(content.search("h1").remove.to_s)
		more = content.search("div[@id*='Comments']").remove.to_s
		content.search("p").each do |p|
			if not p.search("img").empty? or not p.search("object").empty?
				more = p.previous_sibling.following_siblings.remove.to_s + more
				break
			end
		end
		more = Hpricot('<div class="more">' + more.to_s + '</div>')

		wodscroll = page.at("div#WodScroll")
		strength = Hpricot('<br />' + wodscroll.parent.at("h1").to_s + wodscroll.following_siblings.to_s)

		gym.html = Hpricot::Elements[header,content,strength,more]		
		return gym
	end

	def self.endurance(gym)
		page = Hpricot(open(gym.href))
#		gym.html = page.at("div.Post")

		# separate 'more' section
		# img is wrapper in a then p
		# so first parent should be a, second parent should be p
#		img = gym.html.at("p//img")
#		if !img.nil?
#			content = img.parent.parent.previous_sibling
#			more = content.following_siblings.remove
#			# comments are in div id="CommentsForPost-1234"
#			comments = gym.html.search("div[@id*='Comments']").remove
#			more_html = '<div class="more">' + more.to_s + comments.to_s + '</div>'
#		else 
#			content = gym.html.at("div[@id*='Comments']")
#			more_html = '<div class="more">No more!</div>'
#		end
#
#		content.after(more_html)

		wod = page.at("div.Post")
		header = Hpricot(wod.search("h1").remove.to_s)
		comments = Hpricot(wod.search("div[@id*='Comments']").remove.to_s)
		more = Hpricot('')
		wod.search("p").each do |p|
			if !p.search("img").empty?
				# assuming p//img is not the first child
				more = p.previous_sibling.following_siblings.remove	
				break
			end
		end
		more = Hpricot('<div class="more">' + more.to_s + comments.to_s + '</div>')
		wodscroll = page.at("div#WodScroll")
		strength = Hpricot('<br />' + wodscroll.parent.at("h1").to_s + wodscroll.following_siblings.to_s)
		gym.html = Hpricot::Elements[header,wod,strength,more]
		return gym
	end

	def self.socal(gym)
		page = Hpricot(open(gym.href))
		# wod is basic html formatting text
		# kept in p after div#WodScroll
		content = Hpricot(page.at("div#WodScroll").following_siblings.to_html)
		# include 'more' section, might as well include the image from the post
		more = Hpricot('<div class="more">' + page.at("div.Post").to_s + '</div>')
		header = more.search("h1").remove.first

		gym.html = Hpricot::Elements[header, content, more]
		return gym
	end

	def self.strong(gym)
		page = Hpricot(open(gym.href))
		wod = page.at("div#wod_accordion")
		# header is an h4 above the wod div
		header = wod.at("h4")
		# has useless comment text in labal in h4
		header.search("label").remove
		content = wod.at("div")
		# links and imgs above wod removed and move to more
		links = content.search("a").remove
		imgs = content.search("img").remove
		more = Hpricot('<div class="more">' + imgs.to_s + links.to_s + '</div>')
		# remove table with repeat wod info
		content.search("table").remove
		# let's get rid of extra line breaks for now, rely on strong
		#content.search("br").remove
		gym.html = Hpricot::Elements[header, content, more]
		return gym
	end

	def self.asia(gym)
		page = Hpricot(open(gym.href))
		wod = page.search("div.con-box")
		header = wod.at("h3.entry-title")
		content = wod.at("div.entry-body")
		below = String.new
		if not content.search("span.mt-enclosure-image").empty?
			below = content.at("span.mt-enclosure-image").previous_sibling.following_siblings.remove.to_s
		elsif not content.search("object").empty?
			below = content.at("object").previous_sibling.following_siblings.remove.to_s
		end
		comments = wod.at("p.comments")
		more = Hpricot('<div class="more">' + below.to_s + comments.to_s + '</div>')
		gym.html = Hpricot::Elements[header, content, more]
		return gym
	end

	def self.lasvegas(gym)
		page = Hpricot(open(gym.href))
		wod = page.at("div#WodScroll")
		wod = Hpricot(wod.following_siblings.to_s)
		# remove rss info
		wod.search("div.Rss").remove
		# uses Wod Scroll, blog posts aren't always updated
		header = page.at("div#Week div.Active").inner_text
		header = Hpricot('<p><strong>' + header.upcase + '</p></strong>')
		more = Hpricot('<div class="more">Check out <a href="'+gym.href+'">'+gym.title+'</a> for more!</div>')
		gym.html = Hpricot::Elements[header, wod, more]
		return gym
	end

	def self.nineonefour(gym)
		page = Hpricot(open(gym.href))
		wod = page.at("div.post")
		img = nil
		wod.search("address").each do |a|
			if !a.search("img").empty?
				img = a
				break
			end
		end
		more = wod.search("p.postmeta").remove.to_s
		more = img.previous_sibling.following_siblings.remove.to_s + more unless img.nil?
		more = Hpricot('<div class="more">' + more + '</div>')
		# there seems to be an extra period for some reason
		wod.search("address[text()='.']").remove
		gym.html = Hpricot::Elements[wod, more]
		return gym
	end

	def self.ironmajor(gym)
		page = Hpricot(open(gym.href))
		body = page.at("div.post")
		header = body.search("h3.post-title").remove.first
		wod = body.at("div.post-body")
		more = Hpricot('<div class="more">' + body.at("div.post-footer").to_s + '</div>')
		gym.html = Hpricot::Elements[header, wod, more]
		return gym
	end

	def self.brisbane(gym)
		page = Hpricot(open(gym.href))
		body = page.at("div.entry-category-wod")
		header = body.at("h3.entry-header")
		wod = body.at("div.entry-body")
		media = wod.search("div").remove
		footer = body.at("div.entry-footer") 
		more = Hpricot('<div class="more">' + media.to_s + footer.to_s + '</div>')
		gym.html = Hpricot::Elements[header, wod, more]
		return gym
	end	

	def self.aspire(gym)
		page = Hpricot(open(gym.href))
		header = page.at("h2.title[text()*='WOD']")
		wod = Hpricot(header.following_siblings.to_s)
		wod.search("p.post-meta").remove
		more = wod.search("div.post-more").remove
		img = wod.search("img").remove
		more = img.to_s + more.to_s unless img.nil?
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[header, wod, more]
		return gym
	end

	def self.regina(gym)
		page = Hpricot(open(gym.href))
		content = page.search("div.Post-body")[1]
		header = content.at("h2.PostHeaderIcon-wrapper")
		date = content.at("div.PostHeaderIcons")
		date.search("img").remove
		wod = content.at("div.PostContent")
		more = String.new
		media = Array.new
		more = more + wod.search("div.wp-caption").remove.to_s
		media = wod.search("p").collect!{ |p|
			p if not p.search("img").empty? or not p.search("object").empty?
		}.compact.remove
		more = more + media.to_s
		more = more + content.search("div.PostFooterIcons").remove.to_s
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[header, date, wod, more]
		return gym	
	end

	def self.nireland(gym)
		page = Hpricot(open(gym.href))
		content = page.at("div.post")
		header = content.at("h2")
		wod = content.at("div.entry")
		# remove underscore from wod
		wod.search("p[text()*='____']").remove
		more = wod.search("p.postmetadata").remove.to_s
		more = wod.search("div.wp-caption").remove.to_s + more unless wod.search("div.wp-caption").empty?
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[header,wod,more]
		return gym
	end

	def self.belltown(gym)
		page = Hpricot(open(gym.href))
		header = page.at("h2.date-header")
		wod = page.at("div.entry-body")
		more = page.at("div.entry-footer").to_s
		wod.search("p").each do |p|
			if p.next_sibling and not p.next_sibling.search("img").empty?
				more = p.following_siblings.remove.to_s + more
				break
			end
		end
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		# remove iframe in footer
		more.search("iframe").remove
		gym.html = Hpricot::Elements[header,wod,more]
		return gym
	end
	
	def self.losangeles(gym)
#		page = Hpricot(open(gym.href))
#		content = Hpricot(page.search("div.main-3Column-Post")[0].children.to_s)
#		content.search("*").each do |node|
#			if node.text?
#				node.swap('<span>' + node.inner_text + '</span>')
#			end
#		end
#		wod = Hpricot(content.to_s)
#		more = Hpricot(content.to_s)
#		wod.at("hr").preceding_siblings.remove
#		wod.search("div").remove
#		more.at("hr").following_siblings.remove
#		more = Hpricot('<div class="more">' + more.to_s + '</div>')
#		gym.html = Hpricot::Elements[wod,more]

		# use RSS feed rather than site href
		feed = Hpricot(open('http://www.crossfitla.com/cms/index.php/home/rss_2.0-workouts/'))
		wod = Hpricot(feed.at("item").at("description").to_s.gsub(/\n|\r/,'<br />'))
		more = Hpricot('<div class="more">Check out <strong><a href="' + feed.at("item").at("guid").inner_text + '">' + feed.at("item").at("title").inner_text + '</a></strong> for more from Crossfit LA!</div>')
		gym.html = Hpricot::Elements[wod,more]		

		return gym
	end

	def self.cleveland(gym)
		page = Hpricot(open(gym.href))
		content = page.search("div.date-outer")[3]
		header = content.at("h2.date-header")
		wod = content.at("div.entry-content")
		more = content.at("div.post-footer").inner_text.to_s
		more = wod.search("div.separator").remove.to_s + more.to_s unless wod.search("div.separator").empty?
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		# remove multiple breaks
		wod = Hpricot(wod.to_s.gsub(/(\n*<br\s*\/?>){2,}/i,'<br /><br />'))
		gym.html = Hpricot::Elements[header,wod,more]
		return gym
	end

	def self.virtuosity(gym)
		page = Hpricot(open(gym.href))
		wod = page.at("table#latest td.col1")
		wod.search("h2").remove
		more = 'No more!'
		more = wod.at("p").previous_sibling.following_siblings.remove.to_s unless wod.at("p").nil? or wod.at("p").previous_sibling.nil?
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[wod,more]
		return gym
	end

	def self.charlottesville(gym)
		# use RSS feed rather than gym href
		feed = Hpricot(open('http://crossfitcharlottesville.com/feed/'))
		items = feed.search("item")
		item = nil
		items.each do |i|
			if i.at("title").inner_text.match(/workout:/i)
				item = i
				break;
			end
		end
		if item.nil?
			gym.html = Hpricot('No wod found!')
			return gym
		end
		title = Hpricot('<strong>' + item.at("title").inner_text + '</strong><br /><br />')
		wod = Hpricot(item.at("content:encoded").inner_text)
		wod.search("a[@rel='nofollow']").remove
		media = wod.search("p").collect!{ |p|
			p if not p.search("img").empty? or not p.search("object").empty?
		}.compact.remove
		more = 'Checkout <a href="' + item.at("comments").inner_text + '">Crossfit Charlottesville comments</a> for more!'
		more = media.to_s + more.to_s unless media.nil?
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[title,wod,more]
		return gym
	end

	def self.nycendurance(gym)
		page = Hpricot(open(gym.href))
		ewod = page.at("div#content div.entry")
		swod = page.at("div#sidebar div.entry")
		ecomments = '<strong>Endurance Workout:</strong> ' + ewod.search("p.inforight").remove.to_s
		scomments = '<strong>Strength Workout:</strong> ' + swod.search("p.inforight").remove.to_s
		more = Hpricot('<div class="more">' + ecomments.to_s + scomments.to_s + '</div>')
		wod = Hpricot(ewod.to_s + '<br />' + swod.to_s)
		gym.html = Hpricot::Elements[wod,more]
		return gym	
	end

	def self.central(gym)
		page = Hpricot(open(gym.href))
		title = Hpricot(page.at("table.contentpaneopen").inner_text)
		content = page.search("div#fullarticle")[0]
	
		# these contain text that may mess up our WOD search	
		by = content.search("p.writtenby").remove.to_s
		views = content.search("p.viewshits").remove.to_s
		
		content.search("*").each do |e|
			e.swap("<span>" + e.inner_text + "</span>") if e.text?
		end
		
		wod = content.at("p[text()*='WOD']")
		more = wod.at("/span[text()='WOD']").preceding_siblings.remove.to_s

		more = Hpricot('<div class="more">' + more.to_s + '</div>')

		gym.html = Hpricot::Elements[title, wod, more]
		return gym
	end

	def self.element(gym)
		page = Hpricot(open(gym.href))
		content = page.at("div.leading")
		wod = content.at("div.article-content")
		more = wod.search("div.img-desc").remove.to_s
		more = 'No more!' if more.nil?
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		# get rid of comments/views
		wod.search("div.commentBlogView").remove
		gym.html = Hpricot::Elements[wod,more]
		return gym
	end
	
	def self.oneeighty(gym)
		page = Hpricot(open(gym.href))
		content = page.search("div.post")[0]
		header = content.at("h3.post-title")
		wod = content.at("div.post-body")
		wod.search("*").each {|e| e.content=e.content().gsub(/- Posted using BlogPress from my iPhone/i, '') if e.text? }
		more = Hpricot('<div class="more">Check out <a href="http://www.crossfit180.com/"><strong>Crossfit 180</strong></a> for more!</div>')
		gym.html = Hpricot::Elements[header,wod,more]
		return gym
	end

	def self.bravo(gym)
		page = Hpricot(open(gym.href))
		content = page.at("div.entry")
		#header = Hpricot(content.at("span.entry-date").to_s + content.at("h2.entry-title").to_s)
		wod = content.at("div.entry-content")
		more = content.at("p.entry-meta").to_s
		more = wod.search("div.wp-caption").remove.to_s + more.to_s unless wod.search("div.wp-caption").empty?
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[wod,more]
		return gym
	end

	def self.ireland(gym)
		page = Hpricot(open(gym.href))
		wod = page.at("div.featured")
		more = wod.search("p.meta").remove.to_s + wod.search("div.addtoany_share_save_container").remove.to_s
		begin
			if not wod.search("div.wp-caption").empty?
				img = wod.at("div.wp-caption")
				more = img.previous_sibling.following_siblings.remove.to_s + more.to_s
			end
		rescue
			# do nothing
		end
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[wod,more]
		return gym
	end

	def self.scottsdale(gym)
		page = Hpricot(open(gym.href))
		content = page.at("div.post")
		header = content.at("h2")
		wod = content.at("div.entry")
		wod.at("div.sharebar").following_siblings.remove
		wod.search("div.sharebar").remove
		more = 'Check out <a href="http://crossfitscottsdale.com/homeblog/" target="_blank"><strong>Crossfit Scottsdale<strong></a> for more!'
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[header,wod,more]
		return gym
	end

	def self.butcherslab(gym)
		page = Hpricot(open(gym.href))
		header = page.at("h3")
		wod = Hpricot(header.following_siblings.to_s)
		wod.at("hr").following_siblings.remove
		more = 'Check out <a href="http://www.butcherslab.dk/"><strong>Crossfit Butcher\'s Lab</strong></a> for more!'
		more = wod.search("div.image").remove.to_s + more unless wod.search("div.image").empty?
		more = wod.search("div.video").remove.to_s + more unless wod.search("div.video").empty?
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[header,wod,more]
		return gym
	end

	def self.albany(gym)
		page = Hpricot(open(gym.href))
		content = page.search("div.entry")[6]
		header = content.at("h3.entry-header")
		wod = content.at("div.entry-body")
		split = wod.at("//p[text()='WOD']")
		more = split.preceding_siblings.remove.to_s
		if wod.search("//p/a/img/../../p").empty?
			more = more + wod.search("img").remove.to_s unless wod.search("img").empty?
		else
			more = more + wod.search("//p/a/img/../../p").remove.to_s
		end
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[header,wod,more]
		return gym
	end

	def self.lafayette(gym)
		page = Hpricot(open(gym.href))
		content = page.at("div.post")
		header = content.at("h2")
		wod = content.at("div.post-content")
		wod.at("hr").previous_sibling.following_siblings.remove if not wod.at("hr").nil?
		more = 'No more!'
		if not wod.search("center").empty?
			more = wod.at("center").following_siblings.remove.to_s
			more = wod.search("center").remove.to_s + more
		end
		more = Hpricot('<div class="more">' + more.to_s + '</div>')
		gym.html = Hpricot::Elements[header,wod,more]
		return gym
	end
end


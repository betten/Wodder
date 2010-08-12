require 'rubygems'
require 'hpricot'
require 'open-uri'

module Gyms

	@@error = Hpricot('<div class="error">Oh no! An error occurred! We\'re working on a fix and this wod should be back up shortly.</div>')

	def mainsite
		gym = Gym.new('Crossfit Mainsite','http://crossfit.com')
	  begin
		gym = Scrape.mainsite(gym)
		gym.clean_up_html
	  rescue
		gym.html = @@error
	  ensure 
		return gym
	  end
		
	end

	def sealfit
		gym = Gym.new('Sealfit','http://sealfit.com')
	  begin		
		gym = Scrape.sealfit(gym)
		gym.clean_up_html
	  rescue
		gym.html = @@error
	  ensure
		return gym
	  end
	end

	def endurance
		gym = Gym.new('Crossfit Endurance','http://crossfitendurance.com')
#	  begin
		gym = Scrape.endurance(gym)	
		gym.clean_up_html
#	  rescue
#		gym.html = @@error
#	  ensure
		return gym
#	  end
	end

	def socal
		gym = Gym.new('Crossfit Balboa - SoCal S&C','http://socalsc.com')
	  begin		
		gym = Scrape.socal(gym)	
		gym.clean_up_html
	  rescue
		gym.html = @@error
	  ensure		
		return gym
	  end
	end

	def football
		gym = Gym.new('Crossfit Football','http://crossfitfootball.com')
		
	  begin
		gym = Scrape.football(gym)
		gym.clean_up_html
	  rescue
		gym.html = @@error
	  ensure
		return gym
	  end
	end

	def smash
		gym = Gym.new('Crossfit Smash','http://bodytoburn.com.au/crossfit')

	  begin
		gym = Scrape.smash(gym)
		gym.clean_up_html
	  rescue
		gym.html = @@error
	  ensure
		return gym
	  end
	end

	def santacruz
		gym = Gym.new('Crossfit Santa Cruz', 'http://www.crossfitsantacruz.com')
	
	  begin
		gym = Scrape.santacruz(gym)
		gym.clean_up_html
	  rescue

		gym.html = @@error

	  ensure

		return gym

	  end

	end
	
	def oneworld
		gym = Gym.new('Crossfit One World', 'http://www.crossfitoneworld.typepad.com')
#	  begin
		gym = Scrape.oneworld(gym)
		gym.clean_up_html
#	  rescue
#		gym.html = @@error
#	  ensure
		return gym
#	  end
	end

	def strong
		gym = Gym.new('Crossfit Strong', 'http://www.crossfitstrong.com')
	  begin
		gym = Scrape.strong(gym)
		gym.clean_up_html
	  rescue
		gym.html = @@error
	  ensure
		return gym
	  end
	end						

	def asia
		gym = Gym.new('Crossfit Asia', 'http://crossfitasia.com')

		gym = Scrape.asia(gym)
		gym.clean_up_html

		return gym
	end
	
	def lasvegas
		gym = Gym.new('Crossfit Las Vegas', 'http://crossfitlasvegas.com')

		gym = Scrape.lasvegas(gym)
		gym.clean_up_html

		return gym
	end

	def nineonefour
		gym = Gym.new('Crossfit 914', 'http://crossfit914.com/')

		gym = Scrape.nineonefour(gym)
		gym.clean_up_html

		return gym
	end

	def ironmajor
		gym = Gym.new('Iron Major Crossfit', 'http://www.ironmajorcrossfit.com/')

		gym = Scrape.ironmajor(gym)
		gym.clean_up_html

		return gym

	end
	
	def brisbane
		gym = Gym.new('Crossfit Brisbane', 'http://www.crossfitbrisbane.com/')

		gym = Scrape.brisbane(gym)
		gym.clean_up_html

		return gym
	end

	def aspire
		gym = Gym.new('Crossfit Aspire', 'http://crossfitaspire.com/wod/')

		gym = Scrape.aspire(gym)
		gym.clean_up_html

		return gym
	end
end

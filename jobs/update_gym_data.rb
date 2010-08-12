gyms = GymData.all
gyms.each do |data|
	gym = Gym.new(data.title, data.href)
    begin
	gym = Scrape.send data.uid.to_sym, gym
	gym.clean_up_html
    rescue
	gym.html = Hpricot('<div class="error">Oh no! An error occurred! We\'re working on a fix now - this wod should be back up in Fran time!</div>')
    ensure
	data.html = gym.html.to_s
	data.save
    end
end

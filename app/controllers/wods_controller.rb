class WodsController < ApplicationController

  verify :session => :user_id, :redirect_to => '/',
	 :except => :rss
  verify :method => :post, :only => [:save, :delete], :redirect_to => '/'
  verify :params => ['workout','gym'],
	 :only => :save
  verify :params => ['id'],
	 :only => :delete
  layout 'home', :except => [:save, :delete]

  def index
	@wods = Wod.find(:all, :conditions => { :user_id => session[:user_id] })
  end

  def save
	wod = Wod.new
	wod.workout = params[:workout]
	wod.gym_title = params[:gym]
	gym = GymData.find(:first, :conditions => { :title => params[:gym].strip })
	wod.gym_id = gym.id
	wod.user_id = session[:user_id]
	wod.save
  end

  def delete
	wod = Wod.find(:first, :conditions => { :id => params[:id] })
	if wod 
		wod.destroy unless wod.user_id != session[:user_id]
	end
  end

  def rss
	gyms = GymData.all
	out = Array.new
	gyms.each do |data|
		gym = Gym.new(data.title,data.href)
		html = Hpricot(data.html)
		html.search("div.more").remove
		gym.html = html
		out << gym
	end
	@gyms = out
	render :layout => false
	response.header["Content-Type"] = "application/xml; charset=utf-8"
  end

end

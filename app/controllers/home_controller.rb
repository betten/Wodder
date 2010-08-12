require 'gyms'
require 'rubygems'
require 'hpricot'
require 'open-uri'

class HomeController < ApplicationController

  include Gyms 
 
  def index
	Bj.submit './script/runner ./jobs/update_gym_data.rb'
	gyms = GymData.all
	out = Array.new
	gyms.each do |data|
		gym = Gym.new(data.title,data.href)
		gym.html = Hpricot(data.html)
		out << gym
	end
	@gyms = out
  end

end

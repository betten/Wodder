require 'net/https'
require 'uri'

class DonationsController < ApplicationController
  
  verify :params => [:tx, :st, :amt, :cc, :sig],
	 :redirect_to => '/'

  def index
	d = Donation.new :tx => params[:tx], :st => params[:st], :amt => params[:amt], :cc => params[:cc], :sig => params[:sig]
	d.user_id = session[:user_id] if session[:user_id]
	d.save

	if session[:user_id]
		redirect_to '/wods'
	else
		session[:donation] = d.id
		redirect_to '/users/signup'
	end
  end

end

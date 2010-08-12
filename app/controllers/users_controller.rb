class UsersController < ApplicationController

  layout 'home'

  verify :session => :donation, :only => [:signup], :redirect_to => '/'
  verify :session => :user_id, :only => [:update], :redirect_to => '/'

  def signup
	if request.post?
		user = User.new(params[:user])
		if user.save
			session[:user_id] = user.id
			d = Donation.find(:first, :conditions => { :id => session[:donation] })
			d.user_id = user.id
			d.save
			session[:donation] = nil
			redirect_to '/wods'
		else
			flash[:error] = user.errors.full_messages
		end
	end		
  end

  def signin
	if request.post?
		user = User.authenticate(params[:user][:email],params[:user][:password])
		if user
			session[:user_id] = user
			redirect_to '/wods'
		else
			flash[:error] = 'Invalid email or password!'
		end
	end
  end

  def signout
	reset_session
	redirect_to '/'
  end

  def update
	flash[:notice] = flash[:error] = nil
	@user = User.find_by_id(session[:user_id])
	if request.post?
		@user.email = params[:update][:email]
		if not params[:update][:password].empty?
			@user.password = params[:update][:password]
		end
		if not params[:update][:password_confirmation].empty?
			@user.password_confirmation = params[:update][:password_confirmation] 
		end
		if @user.save
			flash[:notice] = 'Updated successfully!'
		else
			flash[:error] = @user.errors.full_messages
		end
	end
  end

end

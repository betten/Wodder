require 'digest/md5'

class User < ActiveRecord::Base
  validates_length_of :email, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_presence_of :email, :password
  validates_uniqueness_of :email
  validates_presence_of :password_confirmation, :if => :password_changed?
  validates_confirmation_of :password
  before_save :hash_password, :if => :password_changed?
  has_many :donations
  has_many :wods

  def self.authenticate(email,password)
	u = find(:first, :conditions => ['email = ?', email])
	#logger.debug 'email => '+email
	#logger.debug 'password => '+password
	return nil if u.nil?
	#logger.debug 'uemail => '+u.email
	#logger.debug 'upassword => '+u.password
	#logger.debug 'pass hash => '+Digest::MD5.hexdigest(password)
	return u.id if u.password == Digest::MD5.hexdigest(password)
	nil
  end

  protected

  def hash_password
	self.password = Digest::MD5.hexdigest(self.password)
  end

end

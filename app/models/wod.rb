require 'rubygems'
require 'hpricot'
require 'digest/md5'

class Wod < ActiveRecord::Base
  belongs_to :user

  def before_validation_on_create
	self.uid = Digest::MD5.hexdigest(Hpricot(self.workout).inner_text.gsub(/\n|\r|\t/,'').gsub(/\s/,''))
  end

  validates_presence_of :workout, :gym_title, :gym_id, :user_id
  validates_uniqueness_of :uid, :scope => :user_id
  validate :validate_gym

  def validate_gym
	GymData.find(:first, :conditions => { :id => self.gym_id })
  end
	
end

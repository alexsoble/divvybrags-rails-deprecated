class Message < ActiveRecord::Base
  attr_accessible :content, :thread_id, :user_id
end

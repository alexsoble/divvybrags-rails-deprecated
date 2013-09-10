class TopicsController < ApplicationController

  def new
    @topic = Topic.new
  end

  def create
    user_id = params[:user_id]
    @topic = Topic.create(params[:topic])
    @topic.user_id = user_id
    if @topic.save
      redirect_to topic_url(@topic)
    end
  end

  def show
    @topic = Topic.find_by_id(params[:id])
  end

end

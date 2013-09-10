class PagesController < ApplicationController

  def home
    if request.env["omniauth.auth"].present? && cookies[:google_drive] == "data_requested"
      @google_drive = true
      auth = request.env["omniauth.auth"]
      @token = auth.credentials.token
    else  
      @google_drive = false
    end
  end

  def leaderboard
    @top_divviers = (Post.all.sort_by &:distance).reverse[0..19]
  end

  def authorize
    cookies[:google_drive] = "data_requested"
    redirect_to "/auth/google"
  end

  def about
  end

  def forum
    @topics = Topic.all
  end

end

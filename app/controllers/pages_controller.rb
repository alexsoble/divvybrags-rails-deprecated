class PagesController < ApplicationController

  def home
  end

  def about
  end

  def leaderboard

    @top_divviers = (Post.all.sort_by &:distance).reverse[0..19]

  end

  def authorize
  end

  def callback
  end

end

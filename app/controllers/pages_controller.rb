class PagesController < ApplicationController

  def home
  end

  def about
  end

  def leaderboard

    @top_divviers = (Post.all.sort_by &:distance).reverse

  end

end

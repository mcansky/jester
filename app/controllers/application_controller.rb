class ApplicationController < ActionController::Base
  protect_from_forgery
  def index
    @github = Github.last
  end

  def update
    @github = Github.last
    Rails.cache.write(:github, @github)
    redirect_to :index
  end
end

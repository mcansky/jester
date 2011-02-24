class ApplicationController < ActionController::Base
  protect_from_forgery
  def index
    @github = nil
    @github = Rails.cache.read :github
    if !@github
      @github = Github.last
      Rails.cache.write(:github, @github)
    end
  end

  def update
    @github = Github.last
    Rails.cache.write(:github, @github)
    redirect_to :index
  end
end

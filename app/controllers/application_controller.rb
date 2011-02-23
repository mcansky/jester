class ApplicationController < ActionController::Base
  protect_from_forgery
  def index
    @github = nil
    @github = Rails.cache.read :github
    if !@github
      @github = Github.new
      @github.repositories
      @github.repositories.keys.each do |repo|
        @github.repositories[repo].open_issues
      end
      Rails.cache.write(:github, @github)
    end
  end

  def update
    @github = Github.new
    @github.repositories
    @github.repositories.keys.each do |repo|
      @github.repositories[repo].open_issues
    end
    Rails.cache.write(:github, @github)
    redirect_to :index
  end
end

require 'digest/sha1'

class Issue < ActiveRecord::Base
  serialize :labels
  belongs_to :repository
  has_many :comments

  def url
    return "https://github.com/#{repository.owner}/#{repository.name}/issues/#issue/#{number}"
  end

  # need to remove this
  def pull_comments
    GithubApi.pull_comments(self)
  end

end
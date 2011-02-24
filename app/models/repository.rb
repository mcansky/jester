require 'digest/sha1'

class Repository < ActiveRecord::Base
  has_many :issues
  belongs_to :github
  before_save :gen_hash

  def gen_hash
    self.hash = Digest::SHA1.hexdigest("#{owner}-#{name}")
  end

  def url
    return "https://github.com/#{owner}/#{name}"
  end

  # need to remove this
  def pull_issues
    GithubApi.pull_issues(self)
  end
end
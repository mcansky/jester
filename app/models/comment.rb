require 'digest/sha1'
class Comment < ActiveRecord::Base
  belongs_to :issue

  def url
    return issue.url
  end

  def repository
    return issue.repository
  end
end
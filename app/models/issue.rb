require 'digest/sha1'

class Issue < Ohm::Model
  attribute :title
  attribute :user
  list :labels, String
  attribute :updated_time # need DateTime.parse !
  attribute :number # need to_i !
  attribute :state
  reference :repository, Repository
  collection :comments, Comment
  attribute :hash

  index :hash

  def initialize(data)
    self.title = data[:title]
    self.user = data[:user]
    self.labels = data[:labels]
    self.updated_at = data[:updated_at]
    self.number = data[:number]
    self.state = data[:state]
    self.repository = data[:repository]
  end

  def url
    return "https://github.com/#{repository.owner}/#{repository.name}/issues/#issue/#{number}"
  end

  # need to remove this
  def get_comments
    comments_raw = Apicall.call("issues/comments/#{user}/#{@repository}/#{number}")["comments"]
    comments = Array.new
    if comments_raw && (comments_raw.count > 1)
      comments_raw.each do |comment|
        comments << Comment.new({:issue_number => number, :repository => @repository, :repository_owner => @repository_owner,
          :user => user, :udpated_at => comment["updated_at"], :id => comment["id"], :body => comment['body']})
      end
      return comments
    end
    return nil
  end

end
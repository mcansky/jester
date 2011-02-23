require 'digest/sha1'

class Repository < Ohm::Model
  attribute :name
  attribute :owner
  collection :open_issues, Issue
  reference :github, Github
  attribute :hash

  index :name
  index :owner
  index :hash


  def set(repository_owner, repository_name)
    self.name = repository_name
    self.owner = repository_owner
    self.hash = Digest::SHA1.hexdigest("#{repository_owner}-#{repository_name}")
  end

  def url
    return "https://github.com/#{owner}/#{name}"
  end

  # need to remove this
  def get_issues(state)
    issues = Apicall.call("issues/list/#{owner}/#{name}/#{state}")['issues']
    if (issues && (issues.count > 0))
      issues.each do |issue|
        if !open_issues.find(:hash => Digest::SHA1.hexdigest("#{issue['number']}-#{issue["title"]}-#{issue['user']}"))
          self.open_issues << Issue.new({:title => issue["title"], :user => issue["user"],
            :labels => issue["labels"], :updated_at => issue["updated_at"],
            :number => issue["number"], :state => issue["state"],
            :repository => name, :repository_owner => owner})
        end
      end
    end
  end
end
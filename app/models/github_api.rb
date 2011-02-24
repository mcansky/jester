module GithubApi
  require 'net/http'
  require 'net/https'

  def self.call(request, user =  Settings.github.user, token = Settings.github.token)
    raise ArgumentError, "user and/or token are not present", nil if (!user || !token)
    begin
      github_payload = "/api/v2/json/#{request}"
      Rails.logger.info("Github API call : #{github_payload}")
      host = "github.com"
      port = "443"

      req = Net::HTTP::Get.new(github_payload)
      req.basic_auth(user+"/token",token)
      httpd = Net::HTTP.new(host, port)
      httpd.use_ssl = true
      response = httpd.request(req)
      Rails.logger.info("\treponse : #{response.code}")
      json_res = JSON.parse(response.body)
      return json_res
    rescue
      raise "ArgumentError : something failed"
    end
  end

  def self.pull_repositories(github_account)
    user_repositories = self.call("repos/show/#{github_account.user}")['repositories']
    organization_repositories = self.call("organizations/#{github_account.organization}/repositories")['repositories']
    (user_repositories + organization_repositories).each do |repository|
      if (!github_account.repositories.find_by_hash(Digest::SHA1.hexdigest("#{repository["owner"]}-#{repository["name"]}"))) || Repository.all.count == 0
        repo = Repository.new(:owner => repository['owner'], :name => repository['name'])
        repo.save
        repo.github = github_account
        repo.save
        Rails.logger.info("[GITHUB] Repository #{repository["owner"]}/#{repository["name"]} #{repo.hash} added")
      else
        Rails.logger.info("[GITHUB] Repository #{repository["owner"]}/#{repository["name"]} already in")
      end
    end
  end

  def self.pull_issues(repository)
    state = "open"
    issues = self.call("issues/list/#{repository.owner}/#{repository.name}/#{state}")['issues']
    issues.each do |issue|
      hash = Digest::SHA1.hexdigest("#{repository.owner}-#{repository.name}-#{issue['number']}")
      if (!repository.issues.find_by_hash(hash))
        c_issue = Issue.new(:title => issue["title"],
          :user => issue["user"],
          :labels => issue["labels"],
          :edited_at => issue["updated_at"],
          :number => issue["number"],
          :state => issue["state"],
          :repository => repository,
          :hash => hash)
        c_issue.save
        Rails.logger.info("[GITHUB] Issue #{repository.owner}/#{repository.name} ##{issue["number"]} added")
      else
        Rails.logger.info("[GITHUB] Issue #{repository.owner}/#{repository.name} ##{issue["number"]} already in")
      end
    end
  end

  def self.pull_comments(issue)
    comments_raw = self.call("issues/comments/#{issue.repository.user}/#{issue.repository.name}/#{issue.number}")["comments"]
    comments_raw.each do |comment|
      hash = Digest::SHA1.hexdigest("#{issue.repository.user}-#{issue.repository.name}-#{issue.number}-#{comment["id"]}")
      if (!issue.comments.find_by_hash(hash))
        c_comment = Comment.new(:issue_number => number,
          :repository => issue.repository,
          :user => user, :edited_at => comment["updated_at"],
          :eid => comment["id"], :body => comment['body'],
          :hash => hash)
        c_comment.save
        Rails.logger.info("[GITHUB] Comment #{issue.repository.user}/#{issue.repository.name}-##{issue.number} ##{comment["id"]} added")
      else
        Rails.logger.info("[GITHUB] Comment #{issue.repository.user}/#{issue.repository.name}-##{issue.number} ##{comment["id"]} already in")
      end
    end
  end
end
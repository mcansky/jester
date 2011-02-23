class Ohm::Model
  def destroy
    Ohm.redis.del("#{self.class}:#{self.id}")
  end
end

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
      puts repository["owner"] + "/" + repository['name']
      if (!github_account.repositories.find(:hash => Digest::SHA1.hexdigest("#{repository["owner"]}-#{repository["name"]}"))) || Repository.all.count == 0
        repo = Repository.new
        repo.set(repository["name"], repository["owner"])
        repo.save
        repo.github = github_account
        repo.save
      end
    end
  end

  def self.pull_issues(repositories)
  end

  def self.pull_comments(issues)
  end
end
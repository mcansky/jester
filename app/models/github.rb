require 'net/http'
require 'net/https'

class Github
  def initialize(user = Settings.github.user,token = Settings.github.token, organization = Settings.github.organization)
    @user = user
    @token = token
    @organization = organization
    @repositories = nil
  end

  def user
    self.api_call("user/show/#{@user}")
  end

  def organization
    self.api_call("organizations/#{@organization}")
  end

  def teams
    self.api_call("organizations/#{@organization}/teams")
  end

  def all_accessible_repositories
    self.api_call("organizations/repositories")
  end

  def organization_repositories
    self.api_call("organizations/#{@organization}/repositories")
  end

  def user_repositories
    self.api_call("repos/show/#{@user}")
  end

  def repositories
    self.get_repositories unless @repositories
    return @repositories
  end
  
  def get_repositories
    @repositories = user_repositories['repositories']
    @repositories += organization_repositories['repositories']
  end

  def repositories_issues
    repositories = organization_repositories['repositories']
    repositories += user_repositories['repositories']
    repo_issues = Array.new
    repositories.each do |repo|
      repo_issues << {:name => repo["name"], :owner => repo['owner'], :url => repo["url"], :open_issues => repo["open_issues"]} if repo["open_issues"] > 0
    end
    return repo_issues
  end

  protected
  def api_call(request)
    begin
      github_payload = "/api/v2/json/#{request}"
      host = "github.com"
      port = "443"

      req = Net::HTTP::Get.new(github_payload)
      req.basic_auth(@user+"/token",@token)
      httpd = Net::HTTP.new(host, port)
      httpd.use_ssl = true
      response = httpd.request(req)
      json_res = JSON.parse(response.body)
      return json_res
    rescue
      "no result found"
    end
  end
end
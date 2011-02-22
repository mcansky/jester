require 'net/http'
require 'net/https'

module Apicall
  def self.call(request)
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
      raise "ArgumentError : something failed"
    end
  end
end

class Repository
  def initialize(name,owner)
    @name = name
    @owner = owner
    @url = "https://github.com/#{owner}/#{name}"
    @open_issues = nil
  end

  attr_reader :name, :owner, :url

  def open_issues
    @open_issues = get_issues("open") unless @open_issues
    return @open_issues
  end

  def get_issues(state)
    issues = Array.new
    puts "issues/list/#{@owner}/#{@name}/#{state}"
    raw_issues = api_call("issues/list/#{@owner}/#{@name}/#{state}")['issues']
    if (raw_issues && (raw_issues.count > 0))
      raw_issues.each do |issue|
        issues << Issue.new(issue["title"], issue["user"], issue["labels"], issue["updated_at"], issue["number"], state, @name, @owner)
      end
    else
      issues = nil
    end
    return issues
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

class Issue
  def initialize(title, user, labels, updated_at, number, state, repository, repository_owner)
    @title = title
    @user = user
    @labels = labels
    @updated_at = updated_at
    @number = number
    @state = state
    @repository = repository
    @repository_owner = repository_owner
  end

  def url
    return "https://github.com/#{@repository_owner}/#{@repository}/issues/#issue/#{@number}"
  end
end

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
    repositories = user_repositories['repositories']
    repositories += organization_repositories['repositories']
    @repositories = Hash.new
    repositories.each do |repo|
      @repositories["#{repo['owner']}/#{repo["name"]}"] = Repository.new(repo["name"], repo['owner'])
    end
  end

  def repositories_issues
    repo_issues = Array.new
    repositories.keys.each do |repo|
      repo_issues << {:name => repositories[repo].name, :owner => repositories[repo].owner, :url => repositories[repo].url, :open_issues => repository_issues(repositories[repo].owner, repositories[repo].name)}
    end
    return repo_issues
  end

  def repository_issues(owner, repository, issues_state = "open")
    issues = api_call("issues/list/#{owner}/#{repository}/#{issues_state}")['issues']
    issues_r = Array.new
    issues.each do |issue|
      issues_r << {:title => issue["title"], :user => issue["user"], :labels => issue["labels"], :updated_at => issue["updated_at"]}
    end
    return issues_r
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
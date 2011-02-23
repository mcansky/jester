module Apicall
  require 'net/http'
  require 'net/https'

  def self.call(request, user =  Settings.github.user, token = Settings.github.token)
    raise ArgumentError, "user and/or token are not present", nil if (!user || !token)
    begin
      github_payload = "/api/v2/json/#{request}"
      #Rails.logger.info(github_payload)
      host = "github.com"
      port = "443"

      req = Net::HTTP::Get.new(github_payload)
      req.basic_auth(user+"/token",token)
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
    self.get_issues("open") unless @open_issues
    return @open_issues
  end

  def get_issues(state)
    issues = Apicall.call("issues/list/#{owner}/#{name}/#{state}")['issues']
    @open_issues = Array.new
    issues.each do |issue|
      @open_issues << Issue.new({:title => issue["title"], :user => issue["user"],
        :labels => issue["labels"], :updated_at => issue["updated_at"],
        :number => issue["number"], :state => issue["state"],
        :repository => name, :repository_owner => owner})
    end
  end
end

class Issue
  def initialize(data)
    @title = data[:title]
    @user = data[:user]
    @labels = data[:labels]
    @updated_at = DateTime.parse(data[:updated_at])
    @number = data[:number]
    @state = data[:state]
    @repository = data[:repository]
    @repository_owner = data[:repository_owner]
  end
  
  attr_reader :title, :user, :labels, :updated_at, :number, :state

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
    Apicall.call("user/show/#{@user}")
  end

  def organization
    Apicall.call("organizations/#{@organization}")
  end

  def teams
    Apicall.call("organizations/#{@organization}/teams")
  end

  def all_accessible_repositories
    Apicall.call("organizations/repositories")
  end

  def organization_repositories
    Apicall.call("organizations/#{@organization}/repositories")
  end

  def user_repositories
    Apicall.call("repos/show/#{@user}")
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
    issues = Apicall.call("issues/list/#{owner}/#{repository}/#{issues_state}")['issues']
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
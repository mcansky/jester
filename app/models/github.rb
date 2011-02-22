require 'net/http'
require 'net/https'

class Github
  def initialize(user,token, organization)
    @user = user || Settings.github.user
    @token = token || Settings.github.token
    @organization = organization || Settings.github.organization
  end

  def user
    self.api_call("user/show/#{@user}")
  end

  def organization
    self.api_call("organizations/#{@organization}")
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
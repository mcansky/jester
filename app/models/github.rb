include GithubApi

class Github < Ohm::Model
  attribute :organization
  attribute :token
  attribute :user
  collection :repositories, Repository

  def set(github_user = Settings.github.user, github_token = Settings.github.token, github_organization = Settings.github.organization)
    self.user = github_user
    self.token = github_token
    self.organization = github_organization
  end

  def pull_repositories
    GithubApi.pull_repositories(self)
  end

end
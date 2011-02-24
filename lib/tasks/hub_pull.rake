namespace :hub_pull do
  desc "Make a full update"
  task :update => :environment do
    hub = nil
    if Github.all.count == 1
      hub = Github.last
    else
      hub = Github.new
      hub.set
      hub.save
    end
    hub.pull_repositories
    hub.repositories.each do |repository|
      repository.pull_issues
      repository.issues.each do |issue|
        issue.pull_comments
      end
    end
  end
end
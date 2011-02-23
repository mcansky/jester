class Comment < Ohm::Model
  reference :issue, Issue
  attribute :updated_at # need DateTime.parse !
  attribute :id # need to_i !
  attribute :user
  attribute :body
  attribute :hash

  index :hash

  def initialize(data)
    self.updated_at = data[:updated_at]
    self.user = data[:user]
    self.id = data[:id]
    self.body = data[:body]
  end

  def repository
    return issue.repository
  end
end
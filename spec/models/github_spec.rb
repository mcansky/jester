require 'spec_helper'

describe Github do
  describe "Initial github should have user, token and organization" do
    subject { Github.new }
    its(:user) { should_not be_nil }
    its(:token) { should_not be_nil }
    its(:organization) { should_not be_nil }
  end
end
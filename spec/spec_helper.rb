# frozen_string_literal: true

require "pathname"
ROOT = Pathname.new(File.expand_path("..", __dir__))
$:.unshift("#{ROOT}lib".to_s)
$:.unshift("#{ROOT}spec".to_s)

require "bundler/setup"
require "rspec"
require "danger"

# Use coloured output, it's the best.
RSpec.configure do |config|
  config.filter_gems_from_backtrace "bundler"
  config.color = true
  config.tty = true
end

require "danger_plugin"

# These functions are a subset of https://github.com/danger/danger/blob/master/spec/spec_helper.rb
# If you are expanding these files, see if it's already been done ^.

# A silent version of the user interface,
# it comes with an extra function `.string` which will
# strip all ANSI colours from the string.

def testing_ui
  @output = StringIO.new
  def @output.winsize
    [20, 9999]
  end

  cork = Cork::Board.new(out: @output)
  def cork.string
    out.string.gsub(/\e\[([;\d]+)?m/, "")
  end
  cork
end

def testing_env
  {
    "GITHUB_ACTION" => "name_of_action",
    "GITHUB_EVENT_NAME" => "pull_request",
    "GITHUB_REPOSITORY" => "danger/danger",
    "GITHUB_EVENT_PATH" => File.expand_path("fixtures/pull_request_event.json", __dir__),
    "GITHUB_TOKEN" => "github_token"
  }
end

def testing_dangerfile
  env = Danger::EnvironmentManager.new(testing_env)
  Danger::Dangerfile.new(env, testing_ui)
end

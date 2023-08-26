# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:specs)

task default: :specs

task :spec do
  Rake::Task["specs"].invoke
  Rake::Task["spec_docs"].invoke
end

desc "Ensure that the plugin passes `danger plugins lint`"
task :spec_docs do
  sh "bundle exec danger plugins lint"
end
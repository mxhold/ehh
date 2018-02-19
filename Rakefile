require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Build README.md from README.md.erb"
task :readme do
  require "erb"
  erb = ERB.new(File.read("README.md.erb"))
  File.write("README.md", erb.result)
end

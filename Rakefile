require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec, :readme]

desc "Build README.md from README.md.erb"
task :readme do
  print "Building README.md from README.md.erb..."
  require "erb"
  erb = ERB.new(File.read("README.md.erb"))
  File.write("README.md", erb.result)
  puts "OK"
end

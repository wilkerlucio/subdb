$: << File.expand_path("../lib", __FILE__)

require "subdb/version"

task :default => [:test]

desc "Download fixture files for tests"
task :download_fixtures do
  puts "need implementation"
end

desc "Run tests"
task :test do
  $: << File.expand_path("../test", __FILE__)

  require "bundler/setup"

  Dir["test/**/*_test.rb"].each do |test|
    require test
  end
end

desc "Build gem"
task :build do
  system "gem build subdb.gemspec"
end

desc "Release gem"
task :release => :build do
  system "gem push subdb-#{Subdb::VERSION}.gem"
end

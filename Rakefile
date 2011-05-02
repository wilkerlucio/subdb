$: << File.expand_path("../lib", __FILE__)

require "subdb/version"

task :default => [:test]

desc "Run tests"
task :test do
  $: << File.expand_path("../test", __FILE__)

  Dir["./test/**/*_test.rb"].each do |test|
    require test
  end
end

desc "Build gem"
task :build do
  system "mkdir -p gem"
  system "gem build subdb.gemspec"
  system "mv subdb-#{Subdb::VERSION}.gem gem"
end

desc "Release gem"
task :release => :build do
  system "gem push gem/subdb-#{Subdb::VERSION}.gem"
end

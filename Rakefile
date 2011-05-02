require 'bundler'
Bundler::GemHelper.install_tasks

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

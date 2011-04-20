# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'subdb/version'

Gem::Specification.new do |s|
  s.name             = "subdb"
  s.version          = Subdb::VERSION
  s.platform         = Gem::Platform::RUBY
  s.authors          = ["Wilker Lucio"]
  s.email            = ["wilkerlucio@gmail.com"]
  s.homepage         = "http://github.com/wilkerlucio/subdb"
  s.summary          = "SubDB Ruby API"
  s.description      = "API for SubDB"
  s.rubygems_version = ">= 1.3.6"
  s.files            = Dir.glob("{bin,lib,vendor/multipart-post}/**/*") + %w{LICENSE README.textile}
  s.executables      = ['subdb']
  s.require_path     = ["lib", "vendor"]
end

Gem::Specification.new do |s|
  s.name = %q{subdb}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Wilker Lucio"]
  s.date = %q{2011-04-19}
  s.description = %q{API for SubDB}
  s.email = %q{wilkerlucio@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.textile"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.textile",
     "Rakefile",
     "lib/subdb.rb",
     "subdb.gemspec",
  ]
  s.homepage = %q{http://github.com/wilkerlucio/mongoid_taggable}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{SubDB Ruby API}
  s.test_files = [
    "test/test_helper.rb",
    "test/subdb_test.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

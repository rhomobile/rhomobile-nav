task :default => :spec

desc 'Run specs (with story style output)'
task 'spec' do
  sh 'rspec spec/'
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rhomobile-nav"
    gemspec.summary = ""
    gemspec.description = ""
    gemspec.homepage = "http://rhomobile.com"
    gemspec.authors = ["David Dollar", "Pedro Belo", "Todd Matthews"]
    gemspec.email = ["david@heroku.com", "pedro@heroku.com", "todd@heroku.com"]

    gemspec.add_development_dependency(%q<rspec>, [">= 2.0.0"])
    gemspec.add_development_dependency(%q<sinatra>, [">= 0"])
    gemspec.add_development_dependency(%q<rack-test>, [">= 0"])
    gemspec.version = '0.0.22' #rake build in folder to upgrade .gemspec file
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

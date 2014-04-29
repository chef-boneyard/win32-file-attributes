require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include('**/*.gem', '**/*.rbc')

namespace :gem do
  desc 'Build the win32-file-attributes gem'
  task :create => [:clean] do
    spec = eval(IO.read('win32-file-attributes.gemspec'))
    if Gem::VERSION >= "2.0"
      require 'rubygems/package'
      Gem::Package.build(spec)
    else
      Gem::Builder.new(spec).build
    end
  end

  desc "Install the win32-file-attributes gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

Rake::TestTask.new do |t|
  task :test => :clean
  t.warning = true
  t.verbose = true
end

task :default => :test

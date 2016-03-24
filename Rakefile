require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

require 'yard'
DOC_FILES = ['lib/**/*.rb']

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = DOC_FILES
end

namespace :doc do
  YARD::Rake::YardocTask.new(:pages) do |t|
    t.files   = DOC_FILES
    t.options = ['-o', '../sitemaps.doc/docs']
  end

  namespace :pages do
    desc 'Checkout gh-pages'
    task :checkout do
      dir = File.dirname(__FILE__) + "/../sitemaps.doc"
      unless Dir.exist?(dir)
        Dir.mkdir(dir)
        Dir.chdir(dir) do
          system 'git init'
          system 'git remote add origin git@github.com:lygaret/sitemaps.git'
          system 'git pull'
          system 'git checkout gh-pages'
        end
      end
    end

    desc 'Generate and publish docs to gh-pages'
    task publish: ['doc:pages:checkout', 'doc:pages'] do
      Dir.chdir(File.dirname(__FILE__) + '/../sitemaps.doc') do
        system 'git checkout gh-pages'
        system 'git add .'
        system 'git add -u'
        system "git commit -m 'Generating docs for version #{Sitemaps::VERSION}.'"
        # system 'git push origin gh-pages'
      end
    end
  end
end

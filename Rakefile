require 'sequel'

$LOAD_PATH << File.expand_path(File.join(__dir__, 'lib'))
$LOAD_PATH << File.expand_path(File.join(__dir__, 'config'))

require 'pry'
require 'yaml'

task :default do
  require 'initializers/ini_database'
end

desc 'Manages database'
namespace :db do
  task :create_database => :default do
    database_config = YAML.safe_load(File.read("config/database.yml"))
    DB["CREATE DATABASE #{database_config['database']}"]
  end

  desc 'Migrate database'
  task :migrate => :default do
    require "sequel/extensions/migration"
    Sequel::IntegerMigrator.new(DB, File.expand_path(File.join(__dir__, 'config/migrations'))).run
  end

  task :migrate_down => :default do
    require "sequel/extensions/migration"
    Sequel::IntegerMigrator.new(DB, File.expand_path(File.join(__dir__, 'config/migrations'), {:target => 0})).run
  end

  task :import => :default do
    DB[:imports].insert(created_time: Time.now.getutc, name: 'Baf')
  end
end

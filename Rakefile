require 'sequel'

$LOAD_PATH << File.expand_path(File.join(__dir__, 'lib'))
$LOAD_PATH << File.expand_path(File.join(__dir__, 'config'))

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
end

task :bin do
  $LOAD_PATH << File.expand_path(File.join(__dir__, 'bin'))
end

namespace :bin do
  task :import => [:default, :bin] do
    require 'import'

    DB[:imports].insert(created_time: Time.now.getutc,
                        name: "Imported #{Import.perform(ENV['file'] || './import.csv')}")
  end
end

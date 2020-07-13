require 'sequel'
require 'logger'
require 'yaml'

ENV['RACK_ENV'] ||= 'development'
content = File.read(File.join(__dir__, '../my_database.yml'))
puts "-- #{content}"
database_config = YAML.load(File.read(File.join(__dir__, '../my_database.yml')))
DB ||= Sequel.connect(ENV['DATABASE_URL'] || database_config[ENV['RACK_ENV']])
DB.loggers << Logger.new($stdout)

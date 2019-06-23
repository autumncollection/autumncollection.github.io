require 'sequel'
require 'logger'
require 'yaml'

ENV['RACK_ENV'] ||= 'development'
database_config = YAML.safe_load(File.read(File.join(__dir__, '../database.yml')))
DB ||= Sequel.connect(database_config[ENV['RACK_ENV']])
DB.loggers << Logger.new($stdout)

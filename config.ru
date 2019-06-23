$LOAD_PATH << File.expand_path(File.join(__dir__, 'lib'))
$LOAD_PATH << File.expand_path(File.join(__dir__, 'config'))

ENV['RACK_ENV'] ||= 'production'

require_relative 'app'

run Headwords::Base

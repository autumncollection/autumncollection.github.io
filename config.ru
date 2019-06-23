$LOAD_PATH << File.expand_path(File.join(__dir__, 'lib'))
$LOAD_PATH << File.expand_path(File.join(__dir__, 'config'))

require_relative 'app'

run Headwords::Base

require 'sinatra'
require 'initializers/ini_database'
# require_relative 'lib/git_class'

module Headwords
  class Base < Sinatra::Base
    get '/' do
      "Haha this in your pipe & smoke it! : #{params['what']}"
    end

    get '/imports' do
      DB[:imports].map do |import|
        "Imported at #{import[:created_time]}"
      end.join("\n")
    end
  end
end

require 'sinatra'
require 'sinatra/bootstrap'

require 'initializers/ini_database'
# require_relative 'lib/git_class'


module Headwords
  class Base < Sinatra::Base
    register Sinatra::Bootstrap::Assets

    helpers do
      def prepare_example(value)
        return '' if value.blank?
        value.gsub(/\*(.+?)\*/, '<b>\1</b>').gsub(/\#(.+?)\#/, '<span style="color: red">\1</span>')
      end

      def active?(path)
        request.path_info =~ /#{Regexp.escape(path)}/ ? 'active' : ''
      end
    end

    get '/all' do
      @data = DB[:headwords].all
      erb :all, :layout => :layout
    end

    get '/find' do
      @data = DB["SELECT h.*, g.grammar, gd.grammar_description, c.category" \
      " FROM headwords h LEFT JOIN categories c ON (c.id = h.category_id)" \
      " LEFT JOIN grammars g ON (g.id = h.grammar_id)" \
      " LEFT JOIN grammar_descriptions gd ON (gd.id = h.grammar_description_id)" \
      " WHERE h.id = ?", params[:what]]
      erb :find, :layout => false
    end

    post '/search' do
      @data = DB[
        "SELECT h.*, g.grammar, gd.grammar_description, c.category" \
        " FROM headwords h LEFT JOIN categories c ON (c.id = h.category_id)" \
        " LEFT JOIN grammars g ON (g.id = h.grammar_id)" \
        " LEFT JOIN grammar_descriptions gd ON (gd.id = h.grammar_description_id)" \
        " WHERE headword = ? OR translation = ?",
          params[:search], params[:search]]
      erb :search, :layout => :layout
    end

    ['/', '/search'].each do |route|
      get route do
        request.path_info = '/search'
        @data = []
        erb :search, :layout => :layout
      end
    end

    get '/imports' do
      DB[:imports].map do |import|
        "Imported at #{import[:created_time]} #{import[:name]}"
      end.join("\n")
    end
  end
end

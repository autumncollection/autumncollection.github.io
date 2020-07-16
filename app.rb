require 'sinatra'
require 'sinatra/bootstrap'

require 'initializers/ini_database'
# require_relative 'lib/git_class'


module Headwords
  class Base < Sinatra::Base
    register Sinatra::Bootstrap::Assets

    helpers do
      def base_query
        "SELECT h.*, g.grammar, gd.grammar_description, cefrs.cefr AS hovno" \
        " FROM headwords h LEFT JOIN cefrs ON (cefrs.id = h.cefr_id)" \
        " LEFT JOIN grammars g ON (g.id = h.grammar_id)" \
        " LEFT JOIN grammar_descriptions gd ON (gd.id = h.grammar_description_id) " \
        " #query# ORDER BY headword ASC"
      end

      def prepare_example(value)
        return '' if value.blank?
        value.gsub(/\*(.+?)\*/, '<b>\1</b>').gsub(/\#(.+?)\#/, '<span style="color: red">\1</span>')
      end

      def active?(path)
        request.path_info =~ /#{Regexp.escape(path)}/ ? 'active' : ''
      end
    end

    get '/all' do
      @data = DB[:headwords].order(:headword).all
      erb :all, :layout => :layout
    end

    get '/cefr/:what/' do
      @data = DB[base_query.sub('#query#',
      " WHERE h.cefr_id = ?"), params[:what]]
      @search = DB[:cefrs].find(id: params[:what]).first[:cefr]
      erb :list, :layout => true
    end

    get '/topic/:what/' do
      @data = DB["SELECT h.headword, h.id FROM headwords h INNER JOIN" \
        " headwords_categories hc ON hc.headword_id = h.id INNER JOIN" \
        " categories c ON c.id = hc.category_id WHERE c.id = ? ORDER BY h.headword ASC", params[:what]]
      @search = DB[:categories].find(id: params[:what]).first[:category]
      erb :list, :layout => true
    end

    get '/label/:what/' do
      @data = DB["SELECT h.headword, h.id FROM headwords h INNER JOIN" \
        " headwords_labels hl ON hl.headword_id = h.id INNER JOIN" \
        " labels l ON l.id = hl.label_id WHERE l.id = ? ORDER BY h.headword ASC", params[:what]]
      @search = DB[:labels].find(id: params[:what]).first[:label]
      erb :list, :layout => true
    end

    get '/detail/:what/' do
      @data = DB[base_query.sub('#query#', " WHERE h.id = ?"), params[:what]]
      erb :find, :layout => true
    end

    get '/find' do
      @data = DB[base_query.sub('#query#', " WHERE h.id = ?"), params[:what]]
      erb :find, :layout => false
    end

    post '/search' do
      @data = DB[base_query.sub('#query#', " WHERE headword LIKE ? OR translation LIKE ?"),
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

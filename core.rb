#####
# Copyright 2011 Lennart Koopmann <lennart@socketfeed.com>
#
# This file is part of mongo_analyzer.
#
# mongo_analyzer is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# mongo_analyzer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with mongo_analyzer.  If not, see <http://www.gnu.org/licenses/>.
#####

require 'erb'
require 'uri'
require 'yaml'
require 'json'
require_relative 'lib/profile'


def connect name
  config = YAML.load_file("config.yml")
  conn = Mongo::Connection.new(config["mongodb"]["host"], config["mongodb"]["port"], {:slave_ok => true})
  if name
    db = conn.db(name)
    if config["mongodb"]["use_auth"]
      db.authenticate(config["mongodb"]["username"], config["mongodb"]["password"], true)
    end
    db
  else
    conn
  end
end

skipped_collections = ["system.users", "system.indexes", "system.profile"]

get '/' do
  conn = connect false
  @databases = conn.database_info.sort_by {|k,v| v}.reverse
  # skipped_databases.each...
  @stats = conn.server_info

  erb :home
end

get '/:database' do
  @database_name = params[:database]
  db = connect @database_name
  @collection_names = db.collection_names
  skipped_collections.each { |collection| @collection_names.delete(collection) }

  case db.profiling_level
    when :off then @profiling_level = "Off"
    when :slow_only then @profiling_level = "Slow only"
    when :all then @profiling_level = "Full"
    else @profiling_level = "Unknown"
  end

  # Slow queries. (Converted to array and flipped for better readable order)
  @profiles = Profile.all db

  @stats = db.stats

  erb :database
end

# should be a post, but fuck this shit.
get '/profiling_level/:database/:what' do
  @database = params[:database]
  db = connect @database
  allowed_types = [:off, :slow_only, :all]
  what = params[:what].to_sym

  if allowed_types.include?(what)
    db.profiling_level = what
    redirect "/#@database"
  else
    "Not allowed profiling level: #{what}. Allowed: #{allowed_types.inspect}"
  end
end

get '/clear_query_log/:database' do
  db = connect params[:database]
  # We must disable profiling before dropping the profile collection.
  old_profile_level = db.profiling_level
  db.profiling_level = :off

  # Drop the logs.
  db.collection("system.profile").drop

  # Set profiling level back to old state.
  db.profiling_level = old_profile_level

  redirect "/#{params[:database]}"
end


get '/indexes/:database/:collection' do
  db = connect params[:database]
  coll = db.collection(params[:collection])
  @indexes = coll.index_information

  erb :indexes
end

get '/drop_index/:database/:collection/:index' do
  db = connect params[:database]
  coll = db.collection(params[:collection])
  coll.drop_index(params[:index])
  redirect "/indexes/#{params[:database]}/#{URI.escape(params[:collection])}"
end

post '/add_index/:database/:collection' do
  db = connect params[:database]
  if params[:ordering] == nil or params[:ordering].length == 0
    ordering = Mongo::ASCENDING
  else
    case (params[:ordering])
      when "ascending" then ordering = Mongo::ASCENDING
      when "descending" then ordering = Mongo::DESCENDING
      else ordering = Mongo::ASCENDING
    end
  end

  options = {}
  [:unique, :sparse, :background].each do |opt|
    options[opt] = true if params[opt] != nil and params[opt] == "true"
  end

  coll = db.collection(params[:collection])
  coll.create_index([[params[:index], ordering]], options)

  redirect "/indexes/#{params[:database]}/#{URI.escape(params[:collection])}"
end

post '/explain/:database' do
  db = connect params[:database]
  collection = params[:ns]
  return 'sys' if collection =~ /^\$|indexes/
  @explain = db[collection].find(params[:query]).explain
  erb :explain, :layout => false
end

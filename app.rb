require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'data_mapper'
require 'sinatra/reloader'


class Todo
	DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required => true
	property :done, Boolean, :required => true, :default => false
	property :created_at, DateTime
	property :updated_at, DateTime
end


DataMapper.finalize.auto_upgrade!

set :port ,7000

get '/' do
	@todos = Todo.all :order => :updated_at.desc
	@title = 'All Notes'
	redirect '/new' if @todos.empty?
	erb :index
end

post '/' do
	ob = Todo.new
	ob.content = params[:content]
	ob.created_at = Time.now
	ob.updated_at = Time.now
	ob.save
	redirect '/'
	#with ajax, this will not be needed
end

get '/:id' do
	@todo = Todo.get params[:id]
	@title = "Edit todo ##{params[:id]}"
	erb:edit
end

put '/:id' do
	n = Todo.get params[:id]
	n.content = params[:content]
	n.done= params[:done] ? 1 : 0
	n.updated_at = Time.now
	n.save
	redirect '/'
end

#Edit the note
get '/:id/delete' do
	@todo = Todo.get params[:id]
	@title = "Confirm deletion of todo ##{params[:id]}"
	erb :delete
end

#delete route

delete '/:id' do
	n = Todo.get params[:id]
	n.destroy
	redirect '/'
end

get '/ajax' do
	@todos.to_json
	@todos = Todo.all :order => :updated_at.desc
	@title = 'All Notes'
	redirect '/new' if @todos.empty?
	erb :index
	end

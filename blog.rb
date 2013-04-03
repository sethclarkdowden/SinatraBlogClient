require 'rubygems'
require 'sinatra' 
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-postgres-adapter'
require './lib/authorization'

DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_MAROON_URL'] || 'postgres://localhost/db')

class Post
	include DataMapper::Resource

	property :id,			Serial
	property :title,		String
	property :content,		Text
	property :auther,		String
	property :created_at,	DateTime
	property :updated_at,	DateTime

	has n, :comments
	has n, :taggings
 	has n, :tags, :through => :taggings
end

class Comment
	include DataMapper::Resource

	property :id,			Serial
	property :name,			String
	property :body,			Text

	belongs_to :post
end

class Tag
	include DataMapper::Resource

	property :id,			Serial
	property :name,			String

	has n, :taggings
	has n, :posts, :through => :taggings
end

class Tagging
	include DataMapper::Resource

	property :id,			Serial

	belongs_to :tag, :key => true
	belongs_to :post, :key => true
end

#Create or upgrade all tables at one 

DataMapper.auto_upgrade!

before do

end

helpers do 
	include Sinatra::Authorization
end

get '/' do
	@title = "Blog"
	@posts = Post.all(:order => [:created_at.desc])
	erb :root
end

get '/post/:id' do
	@post = Post.get(params[:id])
	@tags = @post.tags
	@comments = @post.comments
	if @post
		erb :post
	else
		redirect('/')
	end
end

get '/tags' do
	@tags = Tag.all
	erb :tags
end

get '/posts/:tag' do
	@title = "#{params[:tag]}"
	@post = Tag.get(params[:tag])
	erb :post
end

get '/tag/:name' do
	@tags = Tag.first(:name => params[:name])
	puts @tags.posts
	redirect('/')
end

post '/post/:id/comment/create' do
	@post = Post.get(params[:id]) 	
	@comment = @post.comments.new(params[:comment])
	@comment.save
	
	redirect("/post/#{params[:id]}")
end

get '/new' do 
	require_admin
	@title = "New Blog Post"
	erb :new
end

post '/create' do 
	require_admin
	@post = Post.create(params[:post])
	tags = params[:tags][:name]
	tags = tags.split(',').map{|tag| tag.strip}
	tags.each do |x|
		@post.tags << Tag.first_or_create(:name => x)
	end
	@post.save
	# if @post.save
	# 	redirect "/post/#{@post.id}"
	# else
	 	redirect('/')
	# end
end

get '/delete/:id' do
	require_admin 
	post = Post.get(params[:id])
	post.destroy
	redirect('/')
end

get '/edit/:id' do 
	require_admin
	@post = Post.get(params[:id])
	erb :edit
end 

get '/edit/:id/delete/:tag' do 
	post = Post.get(params[:id])
	tag = post.tags.first(:id => params[:tag])
	tag.destroy
	redirect("edit/#{params[:id]}")
end

post '/update/:id' do 
	require_admin
	@post = Post.get(params[:id])
	@post.update(params[:post])
	tags = params[:tags][:name]
	tags = tags.split(',').map{|tag| tag.strip}
	tags.each do |x|
		@post.tags << Tag.first_or_create(:name => x)
	end
	@post.save
	# if @post.save
	# 	redirect "/post/#{@post.id}"
	# else
	 	redirect('/')
	# end
end




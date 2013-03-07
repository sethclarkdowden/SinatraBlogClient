require 'rubygems'
require 'sinatra' 
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

class Post
	include DataMapper::Resource

	property :id,			Serial
	property :title,		String
	property :content,		Text
	property :auther,		String
	property :created_at,	DateTime
	property :updated_at,	DateTime

	has n, :comments
end

class Comment
	include DataMapper::Resource
	
	property :id,			Serial
	property :post_id,		Serial
	property :name,			String
	property :body,			Text

	belongs_to :post
end

#Create or upgrade all tables at one 

DataMapper.auto_upgrade!

before do

end

get '/' do
	@title = "Blog"
	@posts = Post.all(:order => [:created_at.desc])
	erb :root
end

get '/post/:id' do
	@post = Post.get(params[:id])
	@comments = 1
	@comments = Comment.get(params[:post_id])
	if @post
		erb :post
	else
		redirect('/')
	end
end

get '/new' do 
	@title = "New Blog Post"
	erb :new
end

post '/create' do 
	@post = Post.new(params[:post])
	@post.save
	# if @post.save
	# 	redirect "/post/#{@post.id}"
	# else
	 	redirect('/')
	# end
end

get '/delete/:id' do 
	post = Post.get(params[:id])
	post.destroy
	redirect('/')
end

get '/edit/:id' do 
	@post = Post.get(params[:id])
	erb :edit
end

post '/update/:id' do 
	@post = Post.get(params[:id])
	@post.update(params[:post])
	@post.save
	# if @post.save
	# 	redirect "/post/#{@post.id}"
	# else
	 	redirect('/')
	# end
end




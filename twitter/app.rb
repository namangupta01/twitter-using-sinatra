require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/data.db")

enable:sessions

class User 
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :email, String
	property :password, String
end

class Tweets
	include DataMapper::Resource
	property :id, Serial
	property :user_id, Integer
	property :tweet, String
	property :likes, Integer
	property :dislikes, Integer
	property :name_of_the_tweeter, String 
end

class Likes
	include DataMapper::Resource
	property :id, Serial
	property :tweet_id, Integer
	property :user_id, Integer
end

class Dislikes
	include DataMapper::Resource
	property :id, Serial
	property :name,String
end

class Followers
	include DataMapper::Resource
	property :id,Serial
	property :user_id,Integer
	property :follower_id,Integer
end



DataMapper.finalize
User.auto_upgrade!
Tweets.auto_upgrade!
Likes.auto_upgrade!
Followers.auto_upgrade!
Dislikes.auto_upgrade!
get '/' do
	if session[:user_id] 
		user = User.get(session[:user_id])
		user_id=session[:user_id]
	else 
		redirect '/signin'
	end
	tweets=Tweets.all
	users=User.all
	likes=Likes.all
	followers=Followers.all
	erb :index , locals: {user_id:user_id, tweets:tweets,users:users,user:user,likes:likes,followers:followers}
end

get '/signin' do
	erb :signin
end

post '/signin' do
	email = params[:email]
	password = params[:password]
	user = User.all(:email => email).first
	if user
		if user.password == password
			session[:user_id]=user.id
			redirect '/'
		else
			redirect '/signin'
		end
	else
		redirect '/signup'
	end
end

get '/signup' do
	erb :signup
end

post '/register' do
	email=params[:email]
	password=params[:password]
	name=params[:name]
	user=User.new
	user.name=name
	user.email=email
	user.password=password
	user.save
	session[:user_id]=user.id
	redirect '/'
end

post '/logout' do
	session[:user_id]=nil
	redirect '/'
end

post '/add_tweet' do
	content=params[:tweet]
	tweet=Tweets.new
	tweet.tweet=content
	tweet.user_id=session[:user_id]
	tweet.likes=0
	tweet.dislikes=0
	user=User.all(:id=>session[:user_id]).first
	tweet.name_of_the_tweeter=user.name
	tweet.save
	redirect '/'
	end

post '/on_like_click' do
	tweet_id=params[:tweet_id].to_i
	like=Likes.all(:tweet_id=>tweet_id, :user_id=>session[:user_id]).first
	if like
		tweet=Tweets.get(tweet_id)
		tweet.likes=tweet.likes-1
		tweet.save
		like.destroy

	else
		like=Likes.new
		like.tweet_id=tweet_id
		like.user_id=session[:user_id]
		like.save
		tweet=Tweets.get(tweet_id)
		tweet.likes += 1
		tweet.save
	end
	redirect '/'

end
post '/follow' do

follower_id=params[:follow_id].to_i
	follower=Followers.all(:follower_id=>follower_id, :user_id=>session[:user_id]).first
	if follower
		follower.destroy
	else
		follower=Followers.new
		follower.user_id=session[:user_id]
		follower.follower_id=follower_id
		follower.save
	end
	redirect '/'

end

require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
set :bind, '0.0.0.0'

require_relative 'cookbook'
require_relative 'recipe'

cookbook = Cookbook.new(File.join(__dir__, 'recipes.csv'))

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

get '/' do
  @recipes = cookbook.recipes
  erb :index
end
get '/new' do
  erb :create
end
post '/add_recipe' do
  name = params['name']
  description = params['description']
  prep_time = params['prep_time']
  difficulty = params['difficulty']
  recipe = Recipe.new(name: name, description: description, prep_time: prep_time, difficulty: difficulty)
  cookbook.add_recipe(recipe)
  redirect '/'
end
get '/modify' do
  @index = params['id'].to_i
  @recipe = cookbook.find(@index)
  erb :modify
end
post '/modify_recipe' do
  index = params['id'].to_i
  recipe = cookbook.find(index)
  recipe.name = params['name']
  recipe.description = params['description']
  recipe.prep_time = params['prep_time']
  recipe.difficulty = params['difficulty']
  cookbook.update_recipe
  redirect '/'
end
get '/delete' do
  @index = params['id'].to_i
  @recipe = cookbook.find(@index)
  erb :delete
end
post '/delete_recipe' do
  index = params['id'].to_i
  cookbook.remove_recipe(index)
  redirect '/'
end
post '/mark' do
  @index = params['id'].to_i
  recipe = cookbook.find(@index)
  recipe.mark_as_done!
  cookbook.update_recipe
  url = "/\##{@index}"
  redirect url
end
get '/about' do
  erb :about
end

get '/team' do
  erb :team
end

require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

get("/") do
  "
  <h1>Welcome to your Sinatra App!</h1>
  <p>Define some routes in app.rb</p>
  "
end
get("/cocktail_search"){
  
  erb(:cocktail_search)
}

post("/cocktail_result"){
  @cocktail_name = params.fetch("cocktail_name")

  API = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{CGI.escape(@cocktail_name)}"

  req = HTTP.get(API)
  @res = JSON.parse(req)

  erb(:cocktail_result)
}

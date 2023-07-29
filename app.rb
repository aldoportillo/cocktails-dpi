require "sinatra"
require 'sinatra/main'
require "sinatra/reloader"
require "http"
require "json"

get("/") do

  drink_ids = [11003, 11403, 11001]

  @cocktails = []

  drink_ids.each{|drink_id|

    req = HTTP.get("https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=#{drink_id}")
    res = JSON.parse(req).dig("drinks",0)

    @cocktails.push(res)
  }

  
  erb(:home)
end
get("/cocktail_search"){
  
  erb(:cocktail_search)
}

post("/cocktail_result"){
  @cocktail_name = params.fetch("cocktail_name")

  API = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{CGI.escape(@cocktail_name)}"

  req = HTTP.get(API)
  @res = JSON.parse(req)

  @cocktails = @res.fetch("drinks")

  erb(:cocktail_result)
}

get("/cocktail/:id"){
  @id = params.fetch("id")
  API = "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=#{@id}"

  req = HTTP.get(API)
  @res = JSON.parse(req).dig('drinks', 0)

  @name, @glass, @image, @instructions = @res.dig("strDrink"), @res.dig("strGlass"), @res.dig("strDrinkThumb"), @res.dig("strInstructions")

  @ingredientArr = []

  ingredientNum = 1

  @res.each{|key, value|
    if key.include? "strIngredient"
      if value != nil 
        @ingredientArr.push([value, @res["strMeasure#{ingredientNum}"]])
        ingredientNum += 1
      end
    end
  }

  erb(:cocktail)
}

get("/feeling_lucky"){

  req = HTTP.get("https://www.thecocktaildb.com/api/json/v1/1/random.php")
  @res = JSON.parse(req).dig('drinks', 0)

  @name, @glass, @image, @instructions = @res.dig("strDrink"), @res.dig("strGlass"), @res.dig("strDrinkThumb"), @res.dig("strInstructions")


  @ingredientArr = []

  ingredientNum = 1

  @res.each{|key, value|
    if key.include? "strIngredient"
      if value != nil 
        @ingredientArr.push([value, @res["strMeasure#{ingredientNum}"]])
        ingredientNum += 1
      end
    end
  }

  erb(:cocktail)
}

get("/cocktail_ingredient/:ingredient"){
  @ingredient = params.fetch("ingredient")

  req = HTTP.get("https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=#{@ingredient}")
  @res = JSON.parse(req)

  @cocktails = @res.dig('drinks')
  @cocktail_name = @ingredient
  erb(:cocktail_result)
}

not_found do
  status 404
  erb(:oops)
end

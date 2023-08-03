require "sinatra"
require 'sinatra/main'
require "sinatra/reloader"
require "http"
require "json"
require "sinatra/cookies"

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

  @name, @glass, @image, @instructions, @id = @res.dig("strDrink"), @res.dig("strGlass"), @res.dig("strDrinkThumb"), @res.dig("strInstructions"), @res.dig("idDrink")


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

get("/cocktail_search_dynamic"){
  search_type = params.fetch("search_type")

  if search_type == "ingredient"
    @search_term = params.fetch("search_term")
    @cocktail_name = @search_term #modify @cocktail_name to header in erb file and here later

    req = HTTP.get("https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=#{CGI.escape(@search_term)}")
    @res = JSON.parse(req)

    @cocktails = @res.dig('drinks')
    
  else
    #else defaults to cocktail by name incase there is later more things to search by ie glassware ect
    @search_term = params.fetch("search_term")
    @cocktail_name = @search_term #modify @cocktail_name to header in erb file and here later

    req = HTTP.get("https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{CGI.escape(@search_term)}")
    @res = JSON.parse(req)

    @cocktails = @res.fetch("drinks")

  end

  erb(:cocktail_result)
}

get("/favorites"){

  if cookies["favorite_cocktails"] == nil 
    @favorite_cocktails = []
    cookies["favorite_cocktails"] = JSON.generate(@favorite_cocktails)
  else 
    @favorite_cocktails = JSON.parse(cookies.fetch("favorite_cocktails"))
  end


  erb(:favorite_cocktails)
}

post("/add_favorite/:id/:name/:img"){
  @id = params.fetch("id")
  @name = params.fetch("name")
  @img = params.fetch("img").gsub(":-:", "/")

  if cookies["favorite_cocktails"] == nil 
    @favorite_cocktails = []
    cookies["favorite_cocktails"] = JSON.generate(@favorite_cocktails)
  else 
    @favorite_cocktails = JSON.parse(cookies.fetch("favorite_cocktails"))
  end

  @favorite_cocktails.push({"id" => @id, "name" => @name, "img" => @img})

  cookies["favorite_cocktails"] = JSON.generate(@favorite_cocktails.uniq)

  redirect("/favorites")
}

post("/clear_favorites"){
  cookies["favorite_cocktails"] = JSON.generate([])
  redirect("/favorites")
}

not_found do
  status 404
  erb(:oops)
end

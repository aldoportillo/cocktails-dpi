require "sinatra"
require 'sinatra/main'
require "sinatra/reloader"
require "http"
require "json"
require "sinatra/cookies"

#Global Variable Start
$global = [1]

get("/") do

  drink_ids = [11003, 11403, 11001 ]

  @cocktails = []

  @has_favorites = false

  if cookies["favorite_cocktails"] != nil 
    if JSON.parse(cookies["favorite_cocktails"]).length > 0
      @favorite_cocktails = JSON.parse(cookies.fetch("favorite_cocktails"))
      @has_favorites = true
    end
  end

  drink_ids.each{|drink_id|

    req = HTTP.get("https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=#{drink_id}")
    res = JSON.parse(req).dig("drinks",0)

    @cocktails.push(res)
  }

  
  erb(:home)
end


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
  @header = @ingredient
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

  redirect("/")
}

post("/clear_favorites"){
  cookies["favorite_cocktails"] = JSON.generate([])
  redirect("/")
}



post("/cocktail_search_dynamic"){

  search_type = params.fetch("search_type")
  search_term = params.fetch("search_term")
  @header = search_term

  if search_type == "by_ingredient"

    req = HTTP.get("https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=#{CGI.escape(search_term)}")
    @res = JSON.parse(req)

    @cocktails = @res.dig('drinks')
    
  else
    #else defaults to cocktail by name 

    req = HTTP.get("https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{CGI.escape(search_term)}")
    @res = JSON.parse(req)

    @cocktails = @res.fetch("drinks")

  end
  erb(:cocktail_result)
}


$advanced_search_drinks = []
$ingredients = []

get("/advanced_search"){
  $advanced_search_drinks = []
  $ingredients = []

  erb(:advanced_search)
}

post("/advanced_search"){

  @ingredient = params.fetch("ingredient")

  $ingredients.push(@ingredient)

  req = HTTP.get("https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=#{@ingredient}")
  @res = JSON.parse(req).dig("drinks")

  @new_drinks = []
  @res.each{|drink|
    @new_drinks.push({"id" => drink.fetch("idDrink"), "name" => drink.fetch("strDrink"), "img" => drink.fetch("strDrinkThumb")})
  }
  
  if $advanced_search_drinks != []
    
    merged_drinks = []
    $advanced_search_drinks.each{|drink|
      if @new_drinks.include?(drink)
        merged_drinks.push(drink)
      end
    }

    $advanced_search_drinks = merged_drinks

  else
    $advanced_search_drinks = @new_drinks
  end



  erb(:advanced_search)
}

not_found do
  status 404
  erb(:oops)
end




























# #Legacy Code

# TO GET SEARCH PAGE 

# get("/cocktail_search"){
  
#   erb(:cocktail_search)
# }


# TO GET CERTAIN COCKTAIL BY NAME

# post("/cocktail_result"){
#   @cocktail_name = params.fetch("cocktail_name")

#   API = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{CGI.escape(@cocktail_name)}"

#   req = HTTP.get(API)
#   @res = JSON.parse(req)

#   @cocktails = @res.fetch("drinks")

#   erb(:cocktail_result)
# }

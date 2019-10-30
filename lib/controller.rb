require_relative 'view'

class Controller
  DIFFICULTY_LEVEL = {
    0 => 'difficulté inconnue',
    1 => 'Très Facile',
    2 => 'Facile',
    3 => 'Moyen',
    4 => 'Difficile'
  }

  def initialize(cookbook)
    @cookbook = cookbook
    @view = View.new
  end

  def list
    # => Write list message
    @view.message('list')
    # => get all recipes in cookbook
    recipes = @cookbook.all
    # => display list
    @view.display_list(recipes)
  end

  def create
    # => Write create message
    @view.message('create')
    # => display an empty fill for name then for description
    name = @view.ask_user_for_name
    description = @view.ask_user_for_description
    attributes = { name: name, description: description }
    # => create a recipe
    recipe = Recipe.new(attributes)
    # => store recipe in cookbook
    @cookbook.add_recipe(recipe)
    @view.message('succed')
  end

  def import
    # => Write destroy message
    @view.message('import')
    # => ask for an ingredient and difficulty
    ingredient = @view.ask_user_for_ingredient
    difficulty = @view.ask_user_for_difficulty
    @view.search_message(ingredient)
    # => generate the good url
    url = generate_url(ingredient, difficulty)
    # => recupe data from html
    html_doc = scrap_html(url)
    # => display 5 firste recipes
    @view.display_5_recipes(html_doc)
    # => ask user to select one
    index = @view.ask_user_for_index
    # => recupe le title, la description, le time_prep, la difficulty
    attributes = attributes_for_recipe(html_doc, index, difficulty)
    if !recipe_exist?(attributes[:name])
      # => create Recipe.new
      recipe = Recipe.new(attributes)
      # => store recipe in cookbook
      @cookbook.add_recipe(recipe)
      @view.message('succed')
    else
      @view.message('failed')
      @view.message('recip_exist')
    end
  end

  def destroy
    # => Write destroy message
    @view.message('destroy')
    # => display all the actual recipes
    list
    unless @cookbook.all.empty?
      # => display empty fill for index of recipe
      index = @view.ask_user_for_index
      confirm = @view.confirm
      # => remove recipe by index
      @cookbook.remove_recipe(index) if confirm == 'Y'
      @view.message('succed')
    end
  end

  def modify_recipe
    # => Write create message
    @view.message('modifiy_recipe')
    # => => display all the actual recipes
    list
    # => display empty fill for index of recipe
    index = @view.ask_user_for_index
    confirm = @view.confirm
    if confirm == 'Y'
      recipe = @cookbook.find(index)
      recipe.name = @view.ask_user_for_new_name(recipe)
      recipe.description = @view.ask_user_for_new_description(recipe)
      recipe.prep_time = @view.ask_user_for_new_prep_time(recipe)
      recipe.difficulty = @view.ask_user_for_new_difficulty(recipe)
      @cookbook.update_recipe
      @view.message('succed')
    end
  end

  def mark_as_done
    # => Write create message
    @view.message('mark_as_done')
    # => => display all the actual recipes
    list
    # => display empty fill for index of recipe
    index = @view.ask_user_for_index
    confirm = @view.confirm
    if confirm == 'Y'
      recipe = @cookbook.find(index)
      recipe.mark_as_done!
      @cookbook.update_recipe
      @view.message('succed')
    end
  end

  private

  def scrap_html(url)
    # 'https://www.marmiton.org/recettes/recherche.aspx?type=all&aqt=fraise'
    # https://www.marmiton.org/recettes/recherche.aspx?type=all&aqt=citron&dif=1
    # url = 'fraise.html'

    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    html_doc
  end

  def recipe_exist?(new_recipe_name)
    @cookbook.all.any? do |recipe|
      recipe.name == new_recipe_name
    end
  end

  def attributes_for_recipe(html_doc, index, difficulty = 0)
    {
      name: html_doc.search('h4.recipe-card__title')[index].children.text.strip,
      description: html_doc.search('.recipe-card div.recipe-card__description')[index].children.text.strip,
      prep_time: html_doc.search('span.recipe-card__duration__value')[index].children.text.strip,
      difficulty: DIFFICULTY_LEVEL[difficulty]
    }
  end

  def generate_url(ingredient, difficulty)
    if difficulty.zero?
      url = 'https://www.marmiton.org/recettes/recherche.aspx?type=all&aqt=' + ingredient
    else
      url = "https://www.marmiton.org/recettes/recherche.aspx?type=all&aqt=#{ingredient}&dif=#{difficulty}"
    end
    url
  end
end

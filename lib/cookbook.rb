require 'csv'
require_relative 'recipe'

class Cookbook
  attr_reader :recipes

  def initialize(csv_file = nil)
    @csv_file = csv_file
    @recipes = []
    read_in_csv unless @csv_file.nil?
  end

  def all
    @recipes
  end

  def add_recipe(recipe)
    @recipes << recipe
    update_in_csv unless @csv_file.nil?
  end

  def remove_recipe(index)
    @recipes.delete_at(index)
    update_in_csv unless @csv_file.nil?
  end

  def find(index)
    @recipes[index]
  end

  def update_recipe
    update_in_csv unless @csv_file.nil?
  end

  private

  def update_in_csv
    csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }

    CSV.open(@csv_file, 'wb', csv_options) do |csv|
      @recipes.each do |recipe|
        csv << [recipe.name, recipe.description, recipe.done?.to_s, recipe.prep_time, recipe.difficulty]
      end
    end
    # CSV.open(@csv_file, 'a', csv_options) do |csv|
    #   csv << [recipe.name, recipe.description]
    # end
  end

  def read_in_csv
    csv_options = { col_sep: ',', quote_char: '"' }
    CSV.foreach(@csv_file, csv_options) do |row|
      done = to_bool?(row[2])
      recipe = Recipe.new(name: row[0], description: row[1], done: done, prep_time: row[3], difficulty: row[4])
      @recipes << recipe
    end
  end

  def to_bool?(value)
    value == 'true'
  end

  def find_by_name(name)
    # to do
  end

  def sort_by_done
    # to do
  end

  def sort_by_difficulty
    # to do
  end
end

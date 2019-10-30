class Recipe
  attr_accessor :name, :description, :prep_time, :difficulty

  def initialize(attributes = {})
    @name = attributes[:name]
    @description = attributes[:description]
    @prep_time = attributes[:prep_time]
    @difficulty = attributes[:difficulty]
    @done = attributes.fetch(:done, false)
  end

  def done?
    @done
  end

  def mark_as_done!
    @done = true
  end

  def unmark_as_done
    @done = false
  end
end

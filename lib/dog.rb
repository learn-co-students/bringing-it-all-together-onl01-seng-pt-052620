require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name: , breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(attributes={})
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.new_from_db(dog_array)
    attribute_values = {
    :id => dog_array[0],
    :name => dog_array[1],
    :breed => dog_array[2]
  }
    Dog.new(attribute_values)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).collect {|row| new_from_db(row)}.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_attributes = dog[0]
      initialized_dog = Dog.new(id: dog_attributes[0], name: dog_attributes[1], breed: dog_attributes[2])
      initialized_dog
    else
      new_dog = self.create(name: name, breed: breed)
      new_dog
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).collect {|row| new_from_db(row)}.first
  end

end

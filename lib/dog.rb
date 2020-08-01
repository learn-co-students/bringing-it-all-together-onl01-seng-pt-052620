require 'pry'

class Dog

    attr_accessor :id, :name, :breed

    def initialize(id:nil, name:nil, breed:nil)
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
        );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs;
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        self
    end

    def self.create(attributes)
        new_dog = Dog.new
        attributes.each { |key,val| new_dog.send("#{key}=", val) if new_dog.respond_to?("#{key}=") }
        new_dog.save
    end

    def self.new_from_db(row)
        new_dog = Dog.new(id:row[0], name:row[1], breed:row[2])
        new_dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = (?)"
        Dog.new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = (?) AND breed = (?)"
        if DB[:conn].execute(sql, name, breed) != []
            Dog.new_from_db(DB[:conn].execute(sql, name, breed)[0])
        else
            self.create(name:name, breed:breed)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = (?)"
        Dog.new_from_db(DB[:conn].execute(sql, name)[0])
    end

    def update
        sql = "UPDATE dogs SET name = (?) WHERE id = (?)"
        DB[:conn].execute(sql, self.name, self.id)
    end



end

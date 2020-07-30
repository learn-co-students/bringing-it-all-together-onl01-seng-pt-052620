class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
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
        sql = "DROP TABLE dogs"
        
        DB[:conn].execute(sql)
    end 

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
            SQL
        
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end 
        self
    end 

    def self.create(attributes)
        doggy = Dog.new(attributes)
        doggy.save
    end 
     
    def self.new_from_db(row)
        doggy = Dog.new(id: row[0], name: row[1], breed: row[2])
    end 

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, id)[0].map do |row|
            self.new_from_db(row)
        end.first
    end 

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"

        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            doggy_data = dog[0]
            doggy = Dog.new(id: doggy_data[0], name: doggy_data[1], breed: doggy_data[2])
        else 
            doggy = Dog.create(name: name, breed: breed)
        end 
        doggy
    end 

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, name)[0].map do |row|
            self.new_from_db(row)
        end
    end 






    def update
        
    end 

end 




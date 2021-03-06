require_relative "../config/environment.rb"

class Student
    attr_accessor :name, :grade, :id

    def initialize(id = nil, name, grade)
        @name = name
        @grade = grade
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE students (
            id INTEGER PRIMARY KEY,
            name TEXT,
            grade INTEGER
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS students
        SQL
        DB[:conn].execute(sql)
    end

    def self.find_by_name(name)
        # find the student in the database given a name
        # return a new instance of the Student class
        sql = <<-SQL
            SELECT * FROM students WHERE name = ? LIMIT 1
        SQL

        # student = Student.new
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO students (name, grade)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.grade)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
        end
    end

    def update
        sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

    def self.new_from_db(row)
        student_01 = Student.new(row[0], row[1], row[2])
        # student_01.id = row[0]
        # student_01.name = row[1]
        # student_01.grade = row[2]
        student_01
    end

    def self.create(name, grade)
        Student.new(name, grade).save
    end

end

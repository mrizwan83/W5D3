require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database 
  include Singleton 
  
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end 
end   


class Question 
  attr_accessor :id, :title, :body, :user_id

  def self.find_by_author_id(user_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT *
    FROM questions
    WHERE user_id = ?
    SQL
    return nil unless question

      question.map do |hash|
        Question.new(hash)
      end
  end

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      questions
    WHERE
      id = ?
    SQL
    return nil unless question 
    Question.new(question.first)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
    UPDATE
      questions
    SET
      title = ?, body = ?, user_id = ?
    WHERE
      id = ?
    SQL
  end
end



class User 
  attr_accessor :id, :fname, :lname

  def authored_questions
   Question.find_by_author_id(self.id)
  end

  def self.find_by_name(fname, lname)
    persons = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT * 
    FROM users
    WHERE fname = ? AND lname = ?
    SQL

    return nil unless persons
    persons.map { |person| User.new(person) }
  end


  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already in database" if @id

    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
    UPDATE
      users
    SET
      fname = ?, lname = ?
    WHERE
      id = ?
    SQL
  end
end


class Reply
attr_accessor :id, :question_id, :body, :user_id, :parent_id

  def self.find_by_user_id(author_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT * 
    FROM replies
    WHERE user_id = ?
    SQL

    return nil unless replies
       replies.map do |reply|  
        Reply.new(reply)
      end
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT * 
    FROM replies
    WHERE question_id = ?
    SQL

      return nil unless replies
      replies.map do |reply|  
        Reply.new(reply)
      end
  end
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @body = options['body']
    @user_id = options['user_id']
    @parent_id = options['parent_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @body, @user_id, @parent_id)
      INSERT INTO
        replies (question_id, body, user_id, parent_id)
      VALUES
        (?, ?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @body, @user_id, @parent_id, @id)
    UPDATE
      replies
    SET
      question_id = ?, body = ?, user_id = ?, parent_id = ?
    WHERE
      id = ?
    SQL
  end
end


class QuestionFollows 
  attr_accessor :id, :user_id, :question_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollows.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database" if @id

    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id)
    UPDATE
      question_follows
    SET
      user_id = ?, question_id = ?
    WHERE
      id = ?
    SQL
  end
end

class QuestionLikes 
  attr_accessor :id, :question_id, :user_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLikes.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def create
    raise "#{self} already in database" if @id

    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        question_likes (question_id, user_id)
      VALUES
        (?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id)
    UPDATE
      question_likes
    SET
      question_id = ?, user_id = ?
    WHERE
      id = ?
    SQL
  end
end
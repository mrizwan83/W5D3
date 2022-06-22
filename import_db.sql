DROP TABLE IF EXISTS question_likes; 
DROP TABLE IF EXISTS question_follows; 
DROP TABLE IF EXISTS replies; 
DROP TABLE IF EXISTS questions; 
DROP TABLE IF EXISTS users; 
PRAGMA foreign_keys = ON;


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  parent_id INTEGER,
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Victor', 'Hoang'), ('Mohammad','Rizwan');

INSERT INTO 
  questions (title, body, user_id)
VALUES
  ('HUNGRY?', 'ARE YOU HUNGRY??', 1),
  ('State of being', 'How are you doing today?', (SELECT id FROM users WHERE fname = 'Mohammad'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES 
  (1,2),
  (2,1),
  (1,1),
  (2,2);

INSERT INTO
  replies (question_id, body, user_id, parent_id)
VALUES
  (2, 'great!', 1, NULL),
  (1, 'YES, VERY HUNGRY', 2, NULL),
  (2, 'thats great to hear!', 2, 1),
  (1, 'bet, lets get some food', 1, 2);

INSERT INTO
  question_likes (question_id, user_id)
VALUES 
  (1, 1),
  (1, 2),
  (2, 2);

-- CREATE TABLE posts (
--     id INTEGER PRIMARY KEY,
--     title_portuguese TEXT,
--     title_english TEXT,
--     content_portuguese TEXT,
--     content_english TEXT,
--     date_made DATE default current_date
-- )
PRAGMA foreign_keys;


CREATE TABLE languages (
  id INTEGER PRIMARY KEY,
--     formato iso 639-1
  name TEXT NOT NULL,
--     formato iso 3166-1
  country TEXT NOT NULL
);

PRAGMA foreign_keys = ON;
CREATE TABLE posts (
   id INTEGER PRIMARY KEY,
   language_id INTEGER NOT NULL,
   title TEXT,
   content_md TEXT,
   content_html TEXT,
    content_pure TEXT,
   image_path TEXT,
   date_made DATE default current_date,

   FOREIGN KEY (language_id)
      REFERENCES languages(id)
);
-- ALTER TABLE posts ADD COLUMN slug TEXT;
-- update posts set content_pure = 'damn' where content_pure is null;

CREATE TABLE auth (
  user text not null PRIMARY KEY,
  password text not null
);


PRAGMA foreign_keys = ON;
CREATE TABLE auth_codes
(
  code       text      not null,
  user       text      not null,
  expires_at date_time not null default (datetime('now', '+7 days')),
  primary key (code, user),
  FOREIGN KEY (user)
    REFERENCES auth (user)
);
SELECT user,password FROM auth WHERE user = 'DaviCompai';
DELETE FROM auth_codes WHERE expires_at < datetime('now');
INSERT INTO auth_codes (code,user) VALUES ('code','user');

INSERT INTO posts (language_id, title, content_md,content_html, image_path)
VALUES
    (1,'title example','# example content','<h1>example content</h1>','path/to/image')
;

SELECT title,content_html FROM posts ORDER BY date_made desc;

-- pegar nome completo da lingua e o id
SELECT concat(name,'-',country),id FROM languages;

insert into languages (name,country)
values
    ('pt','br'),
    ('en','us')
;

SELECT code FROM auth_codes WHERE user = ?;
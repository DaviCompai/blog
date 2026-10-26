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
   image_path TEXT,
   date_made DATE default current_date,

   FOREIGN KEY (language_id)
      REFERENCES languages(id)
);

INSERT INTO posts (language_id, title, content_md,content_html, image_path)
VALUES
    (1,'title example','# example content','<h1>example content</h1>','path/to/image')
;

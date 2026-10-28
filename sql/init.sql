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
   slug TEXT,
   image_path TEXT,
   date_made DATE default current_date,

   FOREIGN KEY (language_id)
      REFERENCES languages(id)
);

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

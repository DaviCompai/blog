import tiny_sqlite

const DbPath* = "blog.db"

var
  threadDb {.threadvar.}: DbConn
  threadDbInitialized {.threadvar.}: bool

proc getDb*(): DbConn =
  if not threadDbInitialized:
    threadDb = openDatabase(DbPath)
    threadDb.exec("PRAGMA journal_mode=WAL;")
    threadDb.exec("PRAGMA synchronous=NORMAL;")
    threadDbInitialized = true
  threadDb

template db*: DbConn =
  getDb()

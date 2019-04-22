import sqlite3
import datetime
import json
import os

class Database():
    VERSION = 1
    
    def __init__(self, dataPath=''):
        self._connection = None
        if not dataPath:
            self._dbPath = ':memory:'
        else:
            os.makedirs(dataPath, exist_ok=True)
            self._dbPath = dataPath + '/store.db'

    def init(self):
        self._connection = sqlite3.connect(self._dbPath, detect_types=sqlite3.PARSE_DECLTYPES)
        self._connection.row_factory = sqlite3.Row
        cursor = self._connection.cursor()
        cursor.execute('PRAGMA user_version')
        if cursor.fetchone()['user_version'] is not self.VERSION:
            cursor.execute('DROP TABLE IF EXISTS "gamerecord"')
            cursor.execute('DROP TABLE IF EXISTS "metarecord"')
            cursor.execute('DROP TABLE IF EXISTS "settingsrecord"')
            cursor.execute( "PRAGMA user_version = {v:d}".format(v=self.VERSION) )
        cursor.execute('CREATE TABLE IF NOT EXISTS "gamerecord" ("id" VARCHAR(255) NOT NULL PRIMARY KEY, "installed" INTEGER NOT NULL, "has_update" INTEGER NOT NULL, "created_date" TIMESTAMP NOT NULL, "modified_date" TIMESTAMP, "last_played_date" TIMESTAMP)');
        cursor.execute('CREATE TABLE IF NOT EXISTS "metarecord" ("key" VARCHAR(255) NOT NULL PRIMARY KEY, "value" TEXT NOT NULL)')
        cursor.execute('CREATE TABLE IF NOT EXISTS "settingsrecord" ("key" VARCHAR(255) NOT NULL PRIMARY KEY, "value" TEXT NOT NULL)')
        self._connection.commit()

    def erase(self):
        self._connection.close()
        os.remove(self._dbPath)

    def queryAll(self, query, *args):
        cursor = self._connection.cursor()
        cursor.execute(query, args)
        return cursor.fetchall()

    def queryOne(self, query, *args):
        cursor = self._connection.cursor()
        cursor.execute(query, args)
        return cursor.fetchone()

    def execute(self, query, *args):
        cursor = self._connection.cursor()
        cursor.execute(query, args)
        self._connection.commit()

class MetaRepository():
    def __init__(self, db=None):
        self._db = db

    def get(self, key):
        result = self._db.queryOne('SELECT * FROM metarecord WHERE key = ?', key)
        if not result:
            return None
        else:
            return result['value']

    def set(self, key, value):
        self._db.execute(
            'INSERT OR REPLACE INTO metarecord (key, value) \
            VALUES (?, ?)',
            key, value
        )

class SettingRepository():
    def __init__(self, db=None):
        self._db = db

    def get(self, key):
        result = self._db.queryOne('SELECT * FROM settingsrecord WHERE key = ?', key)
        if not result:
            return None
        else:
            return json.loads(result['value'])

    def set(self, key, value):
        self._db.execute(
            'INSERT OR REPLACE INTO settingsrecord (key, value) \
            VALUES (?, ?)',
            key, json.dumps(value)
        )

class GameRepository():
    def __init__(self, db=None):
        self._db = db

    def get(self, id):
        return self._db.queryOne('SELECT * FROM gamerecord WHERE id = ?', id)

    def set(self, game):
        self._db.execute(
            'INSERT OR REPLACE INTO gamerecord (id, installed, has_update, created_date, modified_date, last_played_date) \
            VALUES (?, ?, ?, ?, ?, ?)',
            game.id, game.installed, game.hasUpdate, game.createdDate, datetime.datetime.now(), game.lastPlayedDate
        )

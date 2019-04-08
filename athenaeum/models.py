from peewee import *
from PyQt5.QtCore import QStandardPaths
import datetime
import json
import os


db_path = QStandardPaths.writableLocation(QStandardPaths.AppDataLocation) + '/athenaeum/store.db'
try:
    db = SqliteDatabase(db_path)
except Error as e:
    sys.exit("Error creating database.")

class BaseModel(Model):
    class Meta:
        database = db

class GameRecord(BaseModel):
    id = CharField(unique=True)
    installed = BooleanField(default=False)
    has_update = BooleanField(default=False)
    created_date = DateTimeField()
    modified_date = DateTimeField(default=datetime.datetime.now)
    last_played_date = DateTimeField(null=True)

class MetaRecord(BaseModel):
    key = CharField(unique=True)
    value = TextField()

class SettingsRecord(BaseModel):
    key = CharField(unique=True)
    value = TextField()

def getMeta(key):
    try:
        return (MetaRecord.get(MetaRecord.key == key)).value
    except DoesNotExist:
        return None

def setMeta(key, value):
    MetaRecord.insert(key=key, value=value).on_conflict(action='REPLACE').execute()

def getSetting(key):
    try:
        return json.loads((SettingsRecord.get(SettingsRecord.key == key)).value)
    except DoesNotExist:
        return None

def setSetting(key, value):
    SettingsRecord.insert(key=key, value=json.dumps(value)).on_conflict(action='REPLACE').execute()

def getGame(id):
    try:
        return GameRecord.get(GameRecord.id == id)
    except DoesNotExist:
        return None

def setGame(game):
    GameRecord.insert(
        id=game.id,
        installed=game.installed,
        has_update=game.hasUpdate,
        created_date=game.createdDate,
        last_played_date=game.lastPlayedDate
    ).on_conflict(action='REPLACE').execute()


def createDatabase():
    try:
        db = SqliteDatabase(db_path)
    except Error as e:
        sys.exit("Error creating database.")

def initDatabase():
    db.connect()
    db.create_tables([GameRecord, MetaRecord, SettingsRecord], safe=True)

def eraseDatabase():
    db.close()
    os.remove(db_path)

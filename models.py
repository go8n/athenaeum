from peewee import *
import datetime

db = SqliteDatabase('store.db')

class BaseModel(Model):
    class Meta:
        database = db

class GameRecord(BaseModel):
    id = CharField(unique=True)
    installed = BooleanField(default=False)
    created_date = DateTimeField(default=datetime.datetime.now)
    modified_date = DateTimeField()
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

def getGame(id):
    try:
        return GameRecord.get(GameRecord.id == id)
    except DoesNotExist:
        return None

def setGame(game):
    GameRecord.insert(
        id=game.id,
        installed=game.installed,
        last_played_date=game.lastPlayedDate,
        modified_date=datetime.datetime.now()
    ).on_conflict(action='REPLACE').execute()

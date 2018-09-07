from peewee import *
from xdg import BaseDirectory
import datetime

try:
    path = BaseDirectory.save_data_path('athenaeum')
    db = SqliteDatabase(path + '/store.db')
except Error as e:
    sys.exit("Error setting up database.")

class BaseModel(Model):
    class Meta:
        database = db

class GameRecord(BaseModel):
    id = CharField(unique=True)
    installed = BooleanField(default=False)
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

def getGame(id):
    try:
        return GameRecord.get(GameRecord.id == id)
    except DoesNotExist:
        return None

def setGame(game):
    GameRecord.insert(
        id=game.id,
        installed=game.installed,
        created_date=game.createdDate,
        last_played_date=game.lastPlayedDate
    ).on_conflict(action='REPLACE').execute()
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

class MetaRecord(BaseModel):
    key = CharField(unique=True)
    value = TextField()

class SettingsRecord(BaseModel):
    key = CharField(unique=True)
    value = TextField()

def getMeta(key):
    try:
        return (MetaRecord.get(MetaRecord.key == 'flathub_added')).value
    except DoesNotExist:
        return None

def setMeta(key, value):
    MetaRecord.replace(key=key, value=value).execute()

def getGame(id):
    try:
        return GameRecord.get(GameRecord.id == id)
    except DoesNotExist:
        return None

def setGame(id, installed):
    GameRecord.replace(
        id=id,
        installed=installed,
        modified_date=datetime.datetime.now()
    ).execute()

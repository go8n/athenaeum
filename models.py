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

class SettingsRecord(BaseModel):
    key = CharField(unique=True)
    value = TextField()

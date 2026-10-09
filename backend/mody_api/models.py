"""Existing v2 SQLite tables. Django must not recreate or rename user tables.

Composite-key tables are accessed by the repository with parameterized SQL.
These ORM models provide normal query access to the single-key entities.
"""
from django.db import models


class Vehicle(models.Model):
    id = models.TextField(primary_key=True)
    label = models.TextField()
    asset_path = models.TextField()
    position = models.IntegerField(default=0)
    sample_position = models.IntegerField(null=True)

    class Meta:
        managed = False
        db_table = 'vehicles'


class Part(models.Model):
    id = models.TextField(primary_key=True)
    asset_path = models.TextField()

    class Meta:
        managed = False
        db_table = 'parts'


class AppSetting(models.Model):
    key = models.TextField(primary_key=True)
    value_json = models.TextField()

    class Meta:
        managed = False
        db_table = 'app_settings'

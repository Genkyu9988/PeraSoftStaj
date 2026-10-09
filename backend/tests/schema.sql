-- v2 schema fixture; contains no user records or credentials.
PRAGMA user_version = 2;
CREATE TABLE android_metadata (locale TEXT);
CREATE TABLE vehicles (
        id TEXT NOT NULL PRIMARY KEY CHECK(length(id) > 0),
        label TEXT NOT NULL,
        asset_path TEXT NOT NULL
      , position INTEGER NOT NULL DEFAULT 0, sample_position INTEGER);
CREATE TABLE creations (
        id TEXT NOT NULL PRIMARY KEY CHECK(length(id) > 0),
        vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
        created_at_us INTEGER NOT NULL,
        kind TEXT NOT NULL CHECK(kind = 'demo'),
        original_image_path TEXT NOT NULL,
        request_type TEXT NOT NULL
          CHECK(request_type IN ('generate', 'explore', 'video')),
        mode TEXT NOT NULL DEFAULT '',
        style TEXT NOT NULL DEFAULT '',
        extra TEXT NOT NULL DEFAULT '',
        color TEXT NOT NULL DEFAULT '',
        angle TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        operation TEXT NOT NULL DEFAULT '',
        option_id TEXT NOT NULL DEFAULT '',
        reference_id TEXT NOT NULL DEFAULT '',
        template TEXT NOT NULL DEFAULT ''
      );
CREATE TABLE migration_log (
        migration_key TEXT NOT NULL PRIMARY KEY,
        completed_at_utc TEXT NOT NULL
      );
CREATE INDEX creations_vehicle_idx ON creations(vehicle_id);
CREATE INDEX creations_type_date_idx ON creations(request_type, created_at_us);
CREATE INDEX creations_date_idx ON creations(created_at_us);
CREATE TABLE part_categories (
      id TEXT PRIMARY KEY NOT NULL, position INTEGER NOT NULL UNIQUE);
CREATE TABLE parts (
      id TEXT PRIMARY KEY NOT NULL CHECK(length(id)>0),
      asset_path TEXT NOT NULL CHECK(length(asset_path)>0));
CREATE TABLE detail_part_options (
      category_id TEXT NOT NULL REFERENCES part_categories(id) ON DELETE RESTRICT,
      slot INTEGER NOT NULL CHECK(slot>=0),
      part_id TEXT NOT NULL REFERENCES parts(id) ON DELETE RESTRICT,
      PRIMARY KEY(category_id, slot), UNIQUE(category_id, part_id));
CREATE TABLE angle_categories (
      angle TEXT NOT NULL, category_id TEXT NOT NULL REFERENCES part_categories(id),
      position INTEGER NOT NULL, PRIMARY KEY(angle, category_id), UNIQUE(angle, position));
CREATE TABLE mod_options (
      operation TEXT NOT NULL, part_id TEXT NOT NULL REFERENCES parts(id),
      position INTEGER NOT NULL, label TEXT NOT NULL, instruction TEXT NOT NULL,
      legacy_name TEXT NOT NULL DEFAULT '', PRIMARY KEY(operation, part_id),
      UNIQUE(operation, position));
CREATE TABLE reference_cars (
      id TEXT PRIMARY KEY NOT NULL, label TEXT NOT NULL, asset_path TEXT NOT NULL,
      position INTEGER NOT NULL UNIQUE);
CREATE TABLE catalog_sections (
      id TEXT PRIMARY KEY NOT NULL, value_type TEXT NOT NULL
      CHECK(value_type IN ('list','strings','integers')));
CREATE TABLE catalog_entries (
      section_id TEXT NOT NULL REFERENCES catalog_sections(id) ON DELETE RESTRICT,
      entry_key TEXT NOT NULL, position INTEGER NOT NULL,
      value_json TEXT NOT NULL, PRIMARY KEY(section_id, entry_key),
      UNIQUE(section_id, position));
CREATE TABLE app_settings (
      key TEXT PRIMARY KEY NOT NULL, value_json TEXT NOT NULL);
CREATE TABLE creation_parts (
      creation_id TEXT NOT NULL REFERENCES creations(id) ON DELETE CASCADE,
      category TEXT NOT NULL, selected_index INTEGER NOT NULL,
      position INTEGER NOT NULL CHECK(position>=0),
      PRIMARY KEY(creation_id, category), UNIQUE(creation_id, position),
      FOREIGN KEY(category,selected_index) REFERENCES detail_part_options(category_id,slot)
        ON DELETE RESTRICT ON UPDATE RESTRICT);
CREATE TRIGGER stable_detail_slots BEFORE UPDATE OF category_id,slot,part_id
      ON detail_part_options BEGIN SELECT RAISE(ABORT, 'Detail slots are immutable'); END;

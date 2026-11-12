-- this is jobwatch database schema
-- RUN psql -h localhost -U jobwatch_app -d jobwatch -v ON_ERROR_STOP=1 -f db/schema.sql

BEGIN;

CREATE TABLE checks(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    kind TEXT NOT NULL CHECK (kind IN ('backup', 'restore_test', 'other')),
    interval_seconds INT NOT NULL CHECK(interval_seconds > 0),
    grace_seconds INT NOT NULL DEFAULT 0 CHECK(grace_seconds >= 0),
    token_hash TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    
);

CREATE TABLE pings (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- Deleting a check also deletes its pings, because pings mean nothing without their check: you can’t tell which job they belong to
    check_id INT NOT NULL REFERENCES checks(id) ON DELETE CASCADE,
    received_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    outcome TEXT NOT NULL CHECK(outcome IN ('success', 'fail')),
    source_ip INET 

);

CREATE INDEX pings_check_id_received_at_idx ON pings (check_id, received_at DESC);

COMMIT;
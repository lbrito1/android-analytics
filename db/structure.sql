CREATE TABLE IF NOT EXISTS "hits" (
  "id" SERIAL,
  "url" varchar(256),
  "ip" varchar(32),
  "user_agent" varchar(256),
  "country" varchar(128),
  "region" varchar(128),
  "city" varchar(128),
  "device" varchar(32),
  "os" varchar(32),
  "lat" decimal(10, 6),
  "long" decimal(10, 6),
  "created_at" timestamp
);

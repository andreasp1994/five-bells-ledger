CREATE TABLE IF NOT EXISTS "L_ACCOUNTS" (
  "ACCOUNT_ID" SERIAL NOT NULL,
  "NAME" CHARACTER VARYING(255) NOT NULL,
  "BALANCE" DECIMAL(32,16) NOT NULL CHECK
    ("BALANCE" >= "MINIMUM_ALLOWED_BALANCE"),
  "CONNECTOR" CHARACTER VARYING(1024) NULL,
  "PASSWORD_HASH" CHARACTER VARYING(1024) NULL,
  "PUBLIC_KEY" CHARACTER VARYING(4000) NULL,
  "IS_ADMIN" SMALLINT NOT NULL,
  "IS_DISABLED" SMALLINT NOT NULL,
  "FINGERPRINT" CHARACTER VARYING(255),
  "MINIMUM_ALLOWED_BALANCE" DECIMAL(32,16) default 0
);

CREATE INDEX "L_XPK_ACCOUNTS" ON "L_ACCOUNTS"
  ("ACCOUNT_ID" ASC);
ALTER TABLE "L_ACCOUNTS" ADD CONSTRAINT "L_PK_ACCOUNTS" PRIMARY KEY
  ("ACCOUNT_ID");
CREATE UNIQUE INDEX "L_XAK_ACCOUNTS" ON "L_ACCOUNTS"
  ("NAME" ASC);
ALTER TABLE "L_ACCOUNTS" ADD CONSTRAINT "L_AK_ACCOUNTS" UNIQUE
  ("NAME");
CREATE INDEX "L_XIE_FINGERPRINT" ON "L_ACCOUNTS"
  ("FINGERPRINT");


CREATE TABLE IF NOT EXISTS "L_LU_REJECTION_REASON" (
  "REJECTION_REASON_ID"   INTEGER NOT NULL,
  "NAME"                  CHARACTER VARYING(10) NOT NULL,
  "DESCRIPTION"           CHARACTER VARYING(255) NULL
);

CREATE INDEX "L_XPK_LU_TRANSFERS_REJECTION_R" ON "L_LU_REJECTION_REASON"
  ("REJECTION_REASON_ID" ASC);
ALTER TABLE "L_LU_REJECTION_REASON" ADD CONSTRAINT
  "L_PK_LU_TRANSFERS_REJECTION_RE"
  PRIMARY KEY ("REJECTION_REASON_ID");
CREATE INDEX "L_XAK_LU_TRANSFERS_REJECTION_R" ON "L_LU_REJECTION_REASON"
  ("NAME" ASC);
ALTER TABLE "L_LU_REJECTION_REASON" ADD CONSTRAINT
  "L_AK_LU_TRANSFERS_REJECTION_RE" UNIQUE
  ("NAME");


CREATE TABLE IF NOT EXISTS "L_TRANSFERS" (
  "TRANSFER_ID" CHARACTER VARYING(36) NOT NULL,
  "LEDGER" CHARACTER VARYING(1024),
  "DEBITS" CHARACTER VARYING(4000),
  "CREDITS" CHARACTER VARYING(4000),
  "ADDITIONAL_INFO" CHARACTER VARYING(4000),
  "STATE" CHARACTER VARYING(20),
  "REJECTION_REASON_ID" INTEGER NULL
    REFERENCES "L_LU_REJECTION_REASON" ("REJECTION_REASON_ID"),
  "EXECUTION_CONDITION" CHARACTER VARYING(4000),
  "CANCELLATION_CONDITION" CHARACTER VARYING(4000),
  "EXPIRES_AT" TIMESTAMP WITH TIME ZONE NULL,
  "PROPOSED_AT" TIMESTAMP WITH TIME ZONE NULL,
  "PREPARED_AT" TIMESTAMP WITH TIME ZONE NULL,
  "EXECUTED_AT" TIMESTAMP WITH TIME ZONE NULL,
  "REJECTED_AT" TIMESTAMP WITH TIME ZONE NULL
);

CREATE INDEX "L_XPK_TRANSFERS" ON "L_TRANSFERS"
  ("TRANSFER_ID" ASC);
ALTER TABLE "L_TRANSFERS" ADD CONSTRAINT "L_PK_TRANSFERS" PRIMARY KEY
  ("TRANSFER_ID");
-- CREATE INDEX "L_XAK_TRANSFERS" ON "L_TRANSFERS"
--   ("TRANSFER_UUID" ASC);
-- ALTER TABLE "L_TRANSFERS" ADD CONSTRAINT "L_AK_TRANSFERS" UNIQUE
--   ("TRANSFER_UUID");
CREATE INDEX "L_XIF_TRANSFERS_STATE" ON "L_TRANSFERS"
  ("STATE" ASC);
CREATE INDEX "L_XIF_TRANSFERS_REASON" ON "L_TRANSFERS"
  ("REJECTION_REASON_ID" ASC);


CREATE TABLE IF NOT EXISTS "L_SUBSCRIPTIONS" (
  "SUBSCRIPTION_ID" CHARACTER VARYING(36) NOT NULL,
  "OWNER" CHARACTER VARYING(255) NOT NULL,
  "EVENT" CHARACTER VARYING(255) NOT NULL,
  "SUBJECT" CHARACTER VARYING(1024) NOT NULL,
  "TARGET" CHARACTER VARYING(1024) NOT NULL,
  "IS_DELETED" BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX "L_XPK_SUBSCRIPTIONS" ON "L_SUBSCRIPTIONS"
  ("SUBSCRIPTION_ID" ASC);
ALTER TABLE "L_SUBSCRIPTIONS" ADD CONSTRAINT "L_PK_SUBSCRIPTIONS" PRIMARY KEY
  ("SUBSCRIPTION_ID");
-- CREATE UNIQUE INDEX "L_XAK_SUBSCRIPTIONS" ON "L_SUBSCRIPTIONS"
--   ("SUBSCRIPTION_UUID" ASC);
-- ALTER TABLE "L_SUBSCRIPTIONS" ADD CONSTRAINT "L_XAK_SUBSCRIPTIONS" UNIQUE
--   ("SUBSCRIPTION_UUID");
CREATE INDEX "L_XIF_SUBSCRIPTIONS_OWNER" ON "L_SUBSCRIPTIONS"
  ("OWNER" ASC);
CREATE INDEX "L_XIF_SUBSCRIPTIONS_SUBJECT" ON "L_SUBSCRIPTIONS"
  ("SUBJECT" ASC);
CREATE INDEX "L_XIE_SUBSCRIPTIONS_DELETED" ON "L_SUBSCRIPTIONS"
  ("IS_DELETED" ASC);


CREATE TABLE IF NOT EXISTS "L_NOTIFICATIONS" (
  "NOTIFICATION_ID" CHARACTER(36) NOT NULL,
  "SUBSCRIPTION_ID" CHARACTER(36) NOT NULL,
  "TRANSFER_ID" CHARACTER(36) NOT NULL,
  "RETRY_COUNT" INTEGER DEFAULT 0 NOT NULL,
  "RETRY_AT" TIMESTAMP WITH TIME ZONE NULL
);

CREATE INDEX "L_XPK_NOTIFICATIONS" ON "L_NOTIFICATIONS"
  ("NOTIFICATION_ID" ASC);
ALTER TABLE "L_NOTIFICATIONS" ADD CONSTRAINT "L_PK_NOTIFICATIONS" PRIMARY KEY
  ("NOTIFICATION_ID");
-- CREATE INDEX "L_XAK_NOTIFICATIONS" ON "L_NOTIFICATIONS"
--   ("NOTIFICATION_UUID" ASC);
-- ALTER TABLE "L_NOTIFICATIONS" ADD CONSTRAINT "L_AK_NOTIFICATIONS" UNIQUE
--   ("NOTIFICATION_UUID");
CREATE INDEX "L_XIE_NOTIFICATIONS_RETRY_AT" ON "L_NOTIFICATIONS"
  ("RETRY_AT" ASC);
CREATE INDEX "L_XIF_NOTIFICATIONS_SUB" ON "L_NOTIFICATIONS"
  ("SUBSCRIPTION_ID" ASC);
CREATE INDEX "L_XIF_NOTIFICATIONS_TRANSFER" ON "L_NOTIFICATIONS"
  ("TRANSFER_ID" ASC);
-- CREATE INDEX "L_XIE_NOTIFICATIONS_DELETED" ON "L_NOTIFICATIONS"
--   ("IS_DELETED" ASC);


CREATE TABLE IF NOT EXISTS "L_ENTRIES" (
  "ENTRY_ID" SERIAL NOT NULL,
  "TRANSFER_ID" CHARACTER(36) NOT NULL,
  "ACCOUNT_ID" INTEGER NOT NULL,
  "CREATED_AT" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "L_XPK_ENTRIES" ON "L_ENTRIES"
  ("ENTRY_ID" ASC);
ALTER TABLE "L_ENTRIES" ADD CONSTRAINT "L_PK_ENTRIES" PRIMARY KEY
  ("ENTRY_ID");
CREATE UNIQUE INDEX "L_XAK_ENTRIES" ON "L_ENTRIES"
  ("TRANSFER_ID" ASC, "ACCOUNT_ID" ASC);
CREATE INDEX "L_XIF_ENTRIES_ACCOUNT" ON "L_ENTRIES"
  ("ACCOUNT_ID" ASC);
CREATE INDEX "L_XIF_ENTRIES_TRANSFER" ON "L_ENTRIES"
  ("TRANSFER_ID" ASC);
CREATE INDEX "L_XIE_ENTRIES_CREATED_AT" ON "L_ENTRIES"
  ("CREATED_AT" ASC);


CREATE TABLE IF NOT EXISTS "L_FULFILLMENTS" (
  "FULFILLMENT_ID" SERIAL NOT NULL,
  "TRANSFER_ID" CHARACTER(36) NOT NULL,
  "CONDITION_FULFILLMENT" CHARACTER VARYING(4000) NOT NULL
);

CREATE INDEX "L_XPK_FULFILLMENTS" ON "L_FULFILLMENTS"
  ("FULFILLMENT_ID" ASC);
ALTER TABLE "L_FULFILLMENTS" ADD CONSTRAINT "PK_FULFILLMENTS" PRIMARY KEY
  ("FULFILLMENT_ID");
CREATE INDEX "L_XIF_FULFILLMENTS" ON "L_FULFILLMENTS"
  ("TRANSFER_ID" ASC);

INSERT INTO "L_LU_REJECTION_REASON" ("REJECTION_REASON_ID", "NAME", "DESCRIPTION")
  VALUES (0, 'cancelled', 'The transfer was cancelled');
INSERT INTO "L_LU_REJECTION_REASON" ("REJECTION_REASON_ID", "NAME", "DESCRIPTION")
  VALUES (1, 'expired', 'The transfer expired automatically');

/*
 * Database structure for Fantabulous.
 *
 * This script should only be used to initialise a new database. It will fail
 * safe in that existing tables and data will not be changed, but you should
 * instead run the migrations scripts to update an existing database in place.
 *
 * We use the utf8mb4 character set to allow Unicode characters from the
 * supplementary planes to ensure that we can support the full range of
 * scripts and, of couse, emoji.
 *
 * InnoDB indexes have a mximum prefix length limit of 3072 bytes with DYNAMIC
 * rows, and 767 with COMPACT rows.
 *
 * This gives us some limits on column legths, as each charcter may be up to
 * four bytes in length:
 *   63 characters is the maximum for a "short" VARCHAR (1-byte length)
 *   16,383 characters is the maximum for a "long" VARCHAR (2-byte length)
 *   191 characters total (plus three spare bytes) per index for COMPACT rows
 *   768 characters total per index for DYNAMIC rows
 *
 * Special cases:
 *   password-related fields are stored in ASCII, for safety
 *   email addresses can only use a subset of ASCII, and are limited to 254
 *     characters in length, as per the RFCs
 */

/*
 * This table simply stores the current version of the database schema.
 */
CREATE TABLE IF NOT EXISTS schema_version (
    version int(10) UNSIGNED NOT NULL PRIMARY KEY
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* Set the initial schema version. */
INSERT IGNORE INTO schema_version SET version = 3;

/*
 * A user of the archive.
 */
CREATE TABLE IF NOT EXISTS users (
    user_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    name VARCHAR(63) NOT NULL,
    email VARCHAR(254) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
    salt CHAR(32) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
    password CHAR(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
    PRIMARY KEY (user_id),
    UNIQUE KEY (name),
    UNIQUE KEY (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* The anonymous user. */
INSERT IGNORE INTO users SET user_id = 1, name = 'Anonymous', password = '',
    salt = '', email = 'anonymous@example.org';

/*
 * A pseudonym. All users must have at least one active pseud, and all their
 * activity is recorded against a pseud taher than directly againstthe user.
 */
CREATE TABLE IF NOT EXISTS pseuds (
    pseud_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id INT(10) UNSIGNED NOT NULL,
    created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    name VARCHAR(63) NOT NULL,
    PRIMARY KEY (pseud_id),
    UNIQUE KEY (user_id,name),
    KEY (name),
    FOREIGN KEY (user_id) REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* The anonymous pseud. */
INSERT IGNORE INTO pseuds SET pseud_id = 1, user_id = 1, name = 'Anonymous';

/*
 * A tag. Fandoms, chracters, relationships, etc are all represented as tags.
 */
CREATE TABLE IF NOT EXISTS tags (
    tag_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    alias_for INT(10) UNSIGNED NOT NULL DEFAULT 1,
    created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    type ENUM('Root','Warning','Fandom','Character','Ship','Generic') NOT NULL,
    name VARCHAR(750) NOT NULL,
    PRIMARY KEY (tag_id),
    UNIQUE KEY (alias_for,name),
    KEY (name),
    FOREIGN KEY (alias_for) REFERENCES tags (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* The root tag, needed to allow canonical tags. */
INSERT IGNORE INTO tags SET tag_id = 1, type = 'Root', name = '__ROOT_TAG__';

/*
 * A Fanwork.
 */
CREATE TABLE IF NOT EXISTS works (
    work_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    version SMALLINT(5) UNSIGNED NOT NULL DEFAULT 1,
    name VARCHAR(750) NOT NULL,
    PRIMARY KEY (work_id),
    KEY (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
 * Maps works to the pseuds who created them.
 */
CREATE TABLE IF NOT EXISTS work_creators (
    work_id INT(10) UNSIGNED NOT NULL,
    pseud_id INT(10) UNSIGNED NOT NULL,
    position TINYINT(3) UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (work_id,position),
    UNIQUE KEY (pseud_id,work_id),
    FOREIGN KEY (work_id) REFERENCES works (work_id),
    FOREIGN KEY (pseud_id) REFERENCES pseuds (pseud_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
 * Maps works to their tags.
 */
CREATE TABLE IF NOT EXISTS work_tags (
    work_id INT(10) UNSIGNED NOT NULL,
    tag_id INT(10) UNSIGNED NOT NULL,
    position SMALLINT(3) UNSIGNED NOT NULL,
    PRIMARY KEY (work_id,position),
    UNIQUE KEY (tag_id,work_id),
    FOREIGN KEY (work_id) REFERENCES works (work_id),
    FOREIGN KEY (tag_id) REFERENCES tags (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
 * A chapter within a fanwork.
 */
CREATE TABLE IF NOT EXISTS chapters (
    chapter_id INT(10) UNSIGNED NOT NULL,
    work_id INT(10) UNSIGNED NOT NULL,
    position SMALLINT(5) UNSIGNED NOT NULL,
    created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    name VARCHAR(750) NOT NULL,
    PRIMARY KEY (chapter_id),
    UNIQUE KEY (work_id,position),
    FOREIGN KEY (work_id) REFERENCES works (work_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
 * A series of fanworks.
 */
CREATE TABLE IF NOT EXISTS series (
    series_id INT(10) UNSIGNED NOT NULL,
    created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    name VARCHAR(750) NOT NULL,
    PRIMARY KEY (series_id),
    KEY (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
 * Maps series to their works.
 */
CREATE TABLE IF NOT EXISTS series_works (
    series_id INT(10) UNSIGNED NOT NULL,
    work_id INT(10) UNSIGNED NOT NULL,
    position SMALLINT(5) UNSIGNED NOT NULL,
    PRIMARY KEY (work_id,series_id),
    UNIQUE KEY (series_id,position),
    FOREIGN KEY (series_id) REFERENCES series (series_id),
    FOREIGN KEY (work_id) REFERENCES works (work_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

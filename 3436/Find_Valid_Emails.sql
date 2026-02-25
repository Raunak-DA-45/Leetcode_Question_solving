/********************************************************************************************
Purpose:
    Retrieve users whose email address is VALID based on a specific business rule.

Business Rules Implemented:
    1. The email must start with one or more letters, numbers, or underscores.
    2. It must contain exactly one '@' symbol.
    3. The domain name must contain only letters (no numbers or special characters).
    4. The email must end with '.com'.
    5. No extra characters are allowed before or after the pattern.

How the Query Works (Step-by-Step):
    1. Create a Users table to store user information.
    2. Insert sample email records (both valid and invalid).
    3. Use REGEXP_LIKE with:
         ^  ? Start of string
         [a-zA-Z0-9_]+ ? Valid username characters
         @  ? Required @ symbol
         [a-zA-Z]+ ? Domain name with letters only
         \\.com ? Must end with ".com"
         $  ? End of string
    4. Sort results by user_id.
********************************************************************************************/

---------------------------------------
-- 1?? TABLE SCHEMA
---------------------------------------

-- Drop table if exists (safe re-run)
DROP TABLE IF EXISTS Users;

-- Create Users table
CREATE TABLE Users (
    user_id INT,              -- Unique identifier for each user
    email VARCHAR(255)        -- Email address of the user
);

---------------------------------------
-- 2?? SAMPLE DATA
---------------------------------------

-- Insert sample users (valid & invalid emails)

INSERT INTO Users (user_id, email) VALUES (1, 'alice@example.com');      -- VALID
INSERT INTO Users (user_id, email) VALUES (2, 'bob_at_example.com');     -- INVALID (missing @)
INSERT INTO Users (user_id, email) VALUES (3, 'charlie@example.net');    -- INVALID (not .com)
INSERT INTO Users (user_id, email) VALUES (4, 'david@domain.com');       -- VALID
INSERT INTO Users (user_id, email) VALUES (5, 'eve@invalid');            -- INVALID (missing .com)

---------------------------------------
-- 3?? MAIN QUERY
---------------------------------------

SELECT *
FROM Users
WHERE REGEXP_LIKE(email, '^[a-zA-Z0-9_]+@[a-zA-Z]+\\.com$')
-- ^ start of string
-- [a-zA-Z0-9_]+  ? username (letters, numbers, underscore)
-- @              ? required symbol
-- [a-zA-Z]+      ? domain name (letters only)
-- \\.com         ? must end with .com
-- $              ? end of string
ORDER BY user_id;

---------------------------------------
-- ? EXPECTED OUTPUT
---------------------------------------
-- user_id | email
-- --------|---------------------
-- 1       | alice@example.com
-- 4       | david@domain.com
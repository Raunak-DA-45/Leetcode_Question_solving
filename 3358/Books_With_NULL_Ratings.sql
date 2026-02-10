/****************************************************************************************
PURPOSE
-------
This script stores book information and identifies books that do not yet have a rating.
Such records are useful for data quality checks or follow-up actions (e.g., collecting
missing reviews).

BUSINESS RULES
--------------
1. Each book has a unique identifier.
2. A book rating is optional and may be NULL if not yet provided.
3. Books with NULL ratings are considered "unrated".
4. Results should be presented in a consistent, ordered format.

HOW THE QUERY WORKS (STEP-BY-STEP)
----------------------------------
1. Create a table to store book details.
2. Insert sample data including both rated and unrated books.
3. Query the table to find books where the rating is missing.
4. Sort the output by book ID for readability.
****************************************************************************************/


/****************************************************************************************
TABLE: books
------------
Stores metadata about books in a library or catalog system.
****************************************************************************************/

CREATE TABLE books (
    book_id INT,             -- Unique identifier for each book
    title VARCHAR(255),      -- Title of the book
    author VARCHAR(100),     -- Author name
    published_year INT,      -- Year the book was published
    rating DECIMAL(3,1)      -- Book rating (1.0–5.0); NULL if not yet rated
);


/****************************************************************************************
SAMPLE DATA
-----------
Includes classic literature titles with some missing ratings.
****************************************************************************************/

TRUNCATE TABLE books;

INSERT INTO books VALUES (1, 'The Great Gatsby',        'F. Scott',        1925, 4.5);
INSERT INTO books VALUES (2, 'To Kill a Mockingbird',   'Harper Lee',       1960, NULL);
INSERT INTO books VALUES (3, 'Pride and Prejudice',     'Jane Austen',     1813, 4.8);
INSERT INTO books VALUES (4, 'The Catcher in the Rye',  'J.D. Salinger',    1951, NULL);
INSERT INTO books VALUES (5, 'Animal Farm',             'George Orwell',   1945, 4.2);
INSERT INTO books VALUES (6, 'Lord of the Flies',       'William Golding',  1954, NULL);


/****************************************************************************************
DATA QUALITY QUERY
------------------
Retrieve all books that do not have a rating.
****************************************************************************************/

SELECT
    book_id,
    title,
    author,
    published_year
FROM books
WHERE rating IS NULL        -- Filters only unrated books
ORDER BY book_id;           -- Ensures predictable output order

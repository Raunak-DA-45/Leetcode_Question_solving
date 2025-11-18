/*
Purpose:
This query retrieves the first name and last name of each person along with their city and state.
If a person does not have an address, the city and state values will be NULL.

How the Query Works:
1. Tables Involved:
   - person: contains personal details like firstname, lastname, and personid.
   - address: contains address details like city, state, and personid.

2. Join Type:
   - LEFT JOIN is used to include all persons, even if they do not have an address.
   - Join condition: a.personid = p.personid.

3. Selected Columns:
   - p.firstname: First name of the person.
   - p.lastname: Last name of the person.
   - a.city: City from the address table (NULL if no address exists).
   - a.state: State from the address table (NULL if no address exists).

4. Result:
   - Returns a complete list of persons with their corresponding city and state if available.
*/

-- Drop tables if they exist
IF OBJECT_ID('address', 'U') IS NOT NULL DROP TABLE address;
IF OBJECT_ID('person', 'U') IS NOT NULL DROP TABLE person;

-- Create Person table
CREATE TABLE person (
    personid INT PRIMARY KEY,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL
);

-- Insert sample data into Person table
INSERT INTO person (personid, firstname, lastname) VALUES
(1, 'John', 'Doe'),
(2, 'Jane', 'Smith'),
(3, 'Alice', 'Johnson'),
(4, 'Bob', 'Brown');

-- Create Address table
CREATE TABLE address (
    addressid INT PRIMARY KEY,
    personid INT NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50),
    CONSTRAINT FK_address_person FOREIGN KEY (personid) REFERENCES person(personid)
);

-- Insert sample data into Address table
INSERT INTO address (addressid, personid, city, state) VALUES
(1, 1, 'New York', 'NY'),
(2, 2, 'Los Angeles', 'CA'),
(3, 4, 'Chicago', 'IL');

-- View the raw tables for reference
SELECT * FROM person;
SELECT * FROM address;

-- Retrieve person details with their city and state if available
SELECT 
    p.firstname,
    p.lastname,
    a.city,
    a.state
FROM person p
LEFT JOIN address a
    ON a.personid = p.personid;

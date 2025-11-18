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

-- Retrieve person details with their city and state if available
SELECT 
    p.firstname,
    p.lastname,
    a.city,
    a.state
FROM person p
LEFT JOIN address a
    ON a.personid = p.personid;

/* ==========================================================================================
   PURPOSE OF THIS SCRIPT
   ------------------------------------------------------------------------------------------
   This script reports the **number of experiments** performed on each platform
   for each experiment type.  
   The core requirement is to return **all possible (platform, experiment_name) pairs**,
   including combinations that do **not** exist in the Experiments table (zero counts).


   HOW THE QUERY WORKS
   ------------------------------------------------------------------------------------------
   1. Build a list of all platforms appearing in the data.
   2. Build a list of all experiment types appearing in the data.
   3. CROSS JOIN these two lists to generate all possible (platform, experiment_name) pairs.
   4. LEFT JOIN this full list to the Experiments table.
   5. COUNT the number of matching experiment_id values ? returns 0 for missing pairs.

   The script includes full table creation, sample data, and a clean, commented solution.
============================================================================================== */



/* ==========================================================================================
   SCHEMA AND SAMPLE DATA
============================================================================================== */

----------------------------------------------------------
-- Drop table if it already exists (makes script rerunnable)
----------------------------------------------------------
IF OBJECT_ID('dbo.Experiments', 'U') IS NOT NULL
    DROP TABLE dbo.Experiments;


----------------------------------------------------------
-- Experiments table
-- experiment_id   : unique ID of the experiment
-- platform        : Android, IOS, or Web
-- experiment_name : Reading, Sports, or Programming
----------------------------------------------------------
CREATE TABLE Experiments (
    experiment_id INT PRIMARY KEY,
    platform VARCHAR(10),
    experiment_name VARCHAR(20)
);


----------------------------------------------------------
-- Sample data simulating experiments conducted
----------------------------------------------------------
INSERT INTO Experiments (experiment_id, platform, experiment_name) VALUES
(4,  'IOS',     'Programming'),
(13, 'IOS',     'Sports'),
(14, 'Android', 'Reading'),
(8,  'Web',     'Reading'),
(12, 'Web',     'Reading'),
(18, 'Web',     'Programming');


----------------------------------------------------------
-- Optional: View loaded data
----------------------------------------------------------
-- SELECT * FROM Experiments;



/* ==========================================================================================
   QUERY: Count experiments for every (platform, experiment_name) pair
============================================================================================== */

-- Step 1: Build all possible pairs using CROSS JOIN on distinct values from the table
WITH all_pairs AS (
    SELECT *
    FROM (SELECT DISTINCT platform FROM Experiments) p
    CROSS JOIN (SELECT DISTINCT experiment_name FROM Experiments) e
)
SELECT 
    ap.platform,
    ap.experiment_name,
    COUNT(ex.experiment_id) AS num_experiments
FROM all_pairs ap
LEFT JOIN Experiments ex
       ON ex.platform = ap.platform
      AND ex.experiment_name = ap.experiment_name
GROUP BY ap.platform, ap.experiment_name
ORDER BY ap.platform, num_experiments DESC;  -- order is flexible per instructions

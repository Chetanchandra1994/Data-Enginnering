{{
  config(
    materialized="table",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_date",
    schema= "dimensions"
  )
}}

-- ============================================================================
-- DATE DIMENSION TABLE WITH CUSTOM enterprise WEEK LOGIC
-- ============================================================================
-- This model creates a date dimension table spanning 76 years (2000-2075)
-- with custom enterprise week numbering that follows ISO-8601 principles but
-- adapted for Sunday-start weeks with special year-end/year-start handling.
--
-- enterprise Week Rules:
-- 1. Weeks run Sunday-Saturday (not Monday-Sunday like standard ISO)
-- 2. Week 1 = week containing first Thursday of year (ISO rule)
-- 3. Week 1 always starts on Jan 1 (even if not Sunday)
-- 4. Year-end: If tail days after last Sunday contain Thursday, create new week
--    Otherwise, merge tail back into previous week (stretched week)
-- ============================================================================

WITH date_raw AS (
  -- Generate one row per day from 2000-01-01 to 2075-12-31
  {{ dbt_utils.date_spine(
      datepart="day", 
      start_date="cast('2000-01-01' as date)", 
      end_date="cast('2075-12-31' as date)"
  ) }}
),

-- ----------------------------------------------------------------------------
-- STEP 1: Calculate Year Anchor Points
-- ----------------------------------------------------------------------------
-- For each date, we need to know 4 key dates of that calendar year:
-- - jan1: First day of the year
-- - week2_start: When Week 2 begins (day after Week 1 ends)
-- - last_sunday: The last Sunday of the year
-- - dec31: Last day of the year
-- ----------------------------------------------------------------------------
week_anchors AS (
  SELECT
    date_day,
    
    -- Jan 1 of the year
    DATE_TRUNC('year', date_day) AS jan1,
    
    -- Week 2 starts on the Sunday following the week containing first Thursday
    -- Logic: Find first Thursday → that week's Saturday → next day (Sunday)
    -- Example 2025: First Thu = Jan 2 → Sat = Jan 4 → Week 2 starts Jan 5
    -- The "-1" ensures we catch Jan 1 if it's a Thursday (NEXT_DAY excludes current date)
    NEXT_DAY(DATE_TRUNC('year', date_day) - 1, 'Thu') + 3 AS week2_start,
    
    -- Last Sunday of the year (important for year-end week calculations)
    -- DAYOFWEEKISO returns 1-7 (Mon-Sun), so % 7 converts Sun=7 to Sun=0
    -- Subtract days back from Dec 31 to reach last Sunday
    -- Example: Dec 31 is Wed (3) → subtract 3 days → Dec 28 (Sun)
    LAST_DAY(date_day, 'year') - (DAYOFWEEKISO(LAST_DAY(date_day, 'year')) % 7) AS last_sunday,
    
    -- Dec 31 of the year
    LAST_DAY(date_day, 'year') AS dec31
  FROM date_raw
),

-- ----------------------------------------------------------------------------
-- STEP 2: Determine Year-End Week Boundary (Thursday Rule)
-- ----------------------------------------------------------------------------
-- Decides whether tail days after last Sunday form a new week or get merged.
-- Rule: Only create new week if tail contains a Thursday (4 days after Sunday)
-- Example 2025: Last Sun = Dec 28, Dec 31 = Wed
--   → Dec 28 + 4 = Jan 1 (next year) → NO Thursday in 2025
--   → Merge: last_week_start = Dec 28 - 7 = Dec 21
-- Example 2027: Last Sun = Dec 26, Dec 31 = Fri  
--   → Dec 26 + 4 = Dec 30 (Thu) ≤ Dec 31 → YES Thursday exists
--   → New week: last_week_start = Dec 26
-- ----------------------------------------------------------------------------
week_boundaries AS (
  SELECT
    date_day,
    jan1,
    week2_start,
    CASE 
      -- If adding 4 days to last Sunday stays within the year, Thursday exists
      WHEN DATEADD('day', 4, last_sunday) <= dec31 
        THEN last_sunday  -- Start new week on last Sunday
      ELSE DATEADD('day', -7, last_sunday)  -- Merge back 7 days (stretch previous week)
    END AS last_week_start
  FROM week_anchors
),

-- ----------------------------------------------------------------------------
-- STEP 3: Calculate enterprise Week Numbers
-- ----------------------------------------------------------------------------
-- Uses a 3-branch CASE to assign week numbers based on date position:
-- Branch 1: Before Week 2 starts → Week 1 (extended, can be 4-9 days)
-- Branch 2: After last_week_start → Final week (frozen number, can be 7-11 days)
-- Branch 3: Everything else → Standard 7-day weeks (count from Week 2 start)
-- ----------------------------------------------------------------------------
week_numbers AS (
  SELECT
    WB.date_day,
    WB.jan1,
    WA.week2_start,
    WB.last_week_start,
    
    CASE
      -- BRANCH 1: Extended Week 1 (Jan 1 through day before Week 2 starts)
      -- Example 2025: Jan 1-4 all become Week 1 (4 days)
      WHEN WB.date_day < WA.week2_start 
        THEN 1
      
      -- BRANCH 2: Year-end frozen week (from last_week_start to Dec 31)
      -- Calculate: How many weeks from Week 2 start to last_week_start, then add 2
      -- Why +2? Because week2_start is Week 2, and FLOOR gives 0-based count
      -- Example 2025: FLOOR((Dec 21 - Jan 5) / 7) + 2 = 50 + 2 = Week 52
      -- All dates Dec 21-31 get same number (frozen)
      WHEN WB.date_day >= WB.last_week_start 
        THEN FLOOR(DATEDIFF('day', WA.week2_start, WB.last_week_start) / 7) + 2
      
      -- BRANCH 3: Standard weeks (normal 7-day Sun-Sat weeks)
      -- Count full weeks since Week 2 started, add 2
      -- Example: Jan 5 → FLOOR(0/7) + 2 = Week 2
      -- Example: Jan 12 → FLOOR(7/7) + 2 = Week 3
      ELSE FLOOR(DATEDIFF('day', WA.week2_start, WB.date_day) / 7) + 2
    END AS enterprise_week_number,
    
    -- Standard ISO week number (Monday-start) shifted by 1 day for Sunday-start
    -- Adding 1 day shifts Sunday from end of previous week to start of current week
    WEEKISO(DATEADD('day', 1, WB.date_day)) AS calendar_week_number
    
  FROM week_boundaries WB
  INNER JOIN week_anchors WA 
    ON WB.date_day = WA.date_day
),

-- ----------------------------------------------------------------------------
-- STEP 4: Calculate enterprise Week Start Dates
-- ----------------------------------------------------------------------------
-- Determines the actual calendar date when each enterprise week began.
-- This is used to calculate the day number within the week (1, 2, 3... etc)
-- ----------------------------------------------------------------------------
week_details AS (
  SELECT
    date_day,
    enterprise_week_number,
    calendar_week_number,
    
    CASE
      -- Week 1 always starts on Jan 1 (even if Jan 1 is not Sunday)
      -- Example 2025: Jan 1 is Wed, but Week 1 starts Jan 1
      WHEN enterprise_week_number = 1 
        THEN jan1
      
      -- Year-end stretched/frozen weeks start at last_week_start
      -- Example 2025: Dec 21-31 all have start date = Dec 21
      WHEN date_day >= last_week_start
        THEN last_week_start
      
      -- Standard weeks start on Sunday (subtract days back to Sunday)
      -- EXTRACT(dayofweek) returns 1=Sun, 2=Mon, 3=Tue... 7=Sat
      -- For Wed (4): subtract (4-1)=3 days to reach Sunday
      -- Example: Jan 8 (Wed) → Jan 8 - 3 = Jan 5 (Sun)
      ELSE DATEADD(day, -(EXTRACT(dayofweek FROM date_day)::INTEGER - 1), date_day)
    END AS enterprise_week_start_date
    
  FROM week_numbers
),

-- ----------------------------------------------------------------------------
-- MAIN DATASET: Assemble Generated Date Dimension
-- ----------------------------------------------------------------------------
main_data AS (
  SELECT 
    -- ========== PRIMARY KEYS ==========
    CAST(DR.date_day AS DATE)::STRING AS DATE_KEY,  -- String format for joins
    DR.date_day::DATE AS FULL_DATE,                -- Date format for display
    
    -- ========== CALENDAR DIMENSIONS ==========
    DATE_PART('year', FULL_DATE)::INTEGER AS CALENDAR_YEAR,
    DATE_PART('month', FULL_DATE)::INTEGER AS CALENDAR_MONTH_NUMBER,
    DATE_PART('day', FULL_DATE)::INTEGER AS CALENDAR_MONTH_DAY_NUMBER,
    DATE_PART('quarter', FULL_DATE)::INTEGER AS CALENDAR_QUARTER_NUMBER,
    CEIL(CALENDAR_QUARTER_NUMBER / 2) AS CALENDAR_SEMESTER_NUMBER,  -- Q1,Q2 → Sem 1; Q3,Q4 → Sem 2
    EXTRACT(dayofweek FROM FULL_DATE)::INTEGER AS CALENDAR_WEEK_DAY_NUMBER,  -- 1=Sun, 7=Sat
    
    -- ========== STANDARD ISO WEEK (Sunday-shifted) ==========
    WD.calendar_week_number::INTEGER AS CALENDAR_WEEK_NUMBER,
    
    -- Standard week begin date (not enterprise, just for reference)
    /*IFF(
      WEEK(FULL_DATE) = 1,
      CONCAT(YEAR(DATE(FULL_DATE)), '-01-01')::DATE,
      DATEADD(day, -(EXTRACT(dayofweek FROM FULL_DATE)::INTEGER - 1), FULL_DATE)
    )*/
    DATEADD(day, -(EXTRACT(dayofweek FROM FULL_DATE)::INTEGER - 1), FULL_DATE) AS CALENDAR_WEEK_START_DATE,
    
    -- ========== MONTH NAMES (FRENCH) ==========
    DECODE(
      CALENDAR_MONTH_NUMBER, 
      1, 'Janvier', 2, 'Février', 3, 'Mars', 4, 'Avril',
      5, 'Mai', 6, 'Juin', 7, 'Juillet', 8, 'Août',
      9, 'Septembre', 10, 'Octobre', 11, 'Novembre', 12, 'Décembre'
    ) AS CALENDAR_MONTH_NAME_FR,
    
    -- ========== MONTH NAMES (ENGLISH) ==========
    TO_CHAR(TO_DATE(FULL_DATE), 'MMMM') AS CALENDAR_MONTH_NAME_EN,
    
    -- ========== DAY NAMES (FRENCH) ==========
    DECODE(
      EXTRACT(dayofweek FROM FULL_DATE),
      1, 'Dimanche', 2, 'Lundi', 3, 'Mardi', 4, 'Mercredi',
      5, 'Jeudi', 6, 'Vendredi', 7, 'Samedi'
    ) AS CALENDAR_DAY_NAME_FR,
    
    -- ========== DAY NAMES (ENGLISH) ==========
    DECODE(
      EXTRACT(dayofweek FROM FULL_DATE),
      1, 'Sunday', 2, 'Monday', 3, 'Tuesday', 4, 'Wednesday',
      5, 'Thursday', 6, 'Friday', 7, 'Saturday'
    ) AS CALENDAR_DAY_NAME_EN,
    
    -- ========== FISCAL PERIOD DIMENSIONS ==========
    -- Joined from separate fiscal calendar table (norm_gl_periods)
    GP.PERIOD_YEAR AS FISCAL_YEAR,
    GP.PERIOD_NUM AS FISCAL_PERIOD_NUMBER,
    GP.PERIOD_NAME AS FISCAL_PERIOD_NAME,
    GP.START_DATE AS FISCAL_PERIOD_START_DATE,
    GP.END_DATE AS FISCAL_PERIOD_END_DATE,
    --NULL::STRING AS FISCAL_QUARTER_NUMBER,   -- Placeholder for future use
    --NULL::STRING AS FISCAL_SEMESTER_NUMBER,  -- Placeholder for future use
    
    -- ========== enterprise WEEK DIMENSIONS ==========
    -- Custom week numbering with ISO-adapted rules for Sunday-start weeks
    WD.enterprise_week_number AS enterprise_WEEK_NUMBER,  -- Week number (1-52 or 1-53)
    
    -- Day number within the enterprise week (1-11, can exceed 7 for stretched weeks)
    -- Calculation: Days since week started + 1
    -- Example: Dec 28 with start Dec 21 → DATEDIFF = 7 → Day 8
    DATEDIFF('day', WD.enterprise_week_start_date, FULL_DATE) + 1 AS enterprise_WEEK_DAY_NUMBER,
    
    -- The date this enterprise week started (Sunday, or Jan 1 for Week 1)
    -- Example: All days Dec 21-31 have start date = Dec 21
    WD.enterprise_week_start_date AS enterprise_WEEK_START_DATE

  FROM date_raw DR
  LEFT JOIN week_details WD 
    ON DR.date_day = WD.date_day
  LEFT JOIN {{ ref('norm_gl_periods') }} GP 
    ON DR.date_day BETWEEN GP.START_DATE AND GP.END_DATE
)

-- ----------------------------------------------------------------------------
-- FINAL SELECT: Assemble Everything Together
-- ----------------------------------------------------------------------------
SELECT * FROM main_data

UNION ALL

-- ----------------------------------------------------------------------------
-- DEFAULT MAX DATE RECORD (9999-12-31)
-- ----------------------------------------------------------------------------
SELECT 
  '9999-12-31'::STRING AS DATE_KEY,
  '9999-12-31'::DATE AS FULL_DATE,
  9999::INTEGER AS CALENDAR_YEAR,
  12::INTEGER AS CALENDAR_MONTH_NUMBER,
  31::INTEGER AS CALENDAR_MONTH_DAY_NUMBER,
  4::INTEGER AS CALENDAR_QUARTER_NUMBER,
  2::INTEGER AS CALENDAR_SEMESTER_NUMBER,
  5::INTEGER AS CALENDAR_WEEK_DAY_NUMBER,
  52::INTEGER AS CALENDAR_WEEK_NUMBER,
  '9999-12-26'::DATE AS CALENDAR_WEEK_START_DATE,
  'Décembre'::STRING AS CALENDAR_MONTH_NAME_FR,
  'December'::STRING AS CALENDAR_MONTH_NAME_EN,
  'Vendredi'::STRING AS CALENDAR_DAY_NAME_FR,
  'Friday'::STRING AS CALENDAR_DAY_NAME_EN,
  9999::INTEGER AS FISCAL_YEAR,
  12::INTEGER AS FISCAL_PERIOD_NUMBER,
  'Period 12'::STRING AS FISCAL_PERIOD_NAME,
  '9999-12-01 00:00:00.000'::TIMESTAMP AS FISCAL_PERIOD_START_DATE,
  NULL::TIMESTAMP AS FISCAL_PERIOD_END_DATE,
  --'Q4'::STRING AS FISCAL_QUARTER_NUMBER,
  --'S2'::STRING AS FISCAL_SEMESTER_NUMBER,
  NULL::INTEGER AS enterprise_WEEK_NUMBER,
  NULL::INTEGER AS enterprise_WEEK_DAY_NUMBER,
  NULL::DATE AS enterprise_WEEK_START_DATE
USE smarthome;

-- ===============================================================
--  SENSOR LOCATION AND ROOM NORMALIZATION SCRIPT
-- ===============================================================
--  Purpose:
--    - Ensures consistent values for location, precise_location, and room
--    - Can be run periodically for data quality checks
--
-- ===============================================================
--  RULE SUMMARY (name → location / precise_location / room)
-- ===============================================================
--  [MOBILE DEVICES]
--    * name LIKE '%iphone%' or '%ipad_%' → mobile device / mobile device / mobile device
--    * name LIKE '%arvopaukkunen_arvohomeassistant%' → Livingroom / Server rack / Server room
--
--  [OUTLETS]
--    outlet_2_power  → House / Between East, Windows / Spa
--    outlet_4_power  → House / East South Corner / Kitchen
--    outlet_6_power  → House / Left From South Windows / Spa
--    outlet_7_power  → House / Middle of South Windows / Kitchen
--    outlet_9_power  → House / Left From West Door / Kitchen
--    outlet_10_power → House / Rightmost Next to AC Power / Livingroom
--    outlet_11_power → House / Leftmost Next To AC Power / Livingroom
--    outlet_12_power → House / Leftmost Up In Staircase / Livingroom
--    outlet_13_power → House / Rightmost Up In Staricase / Livingroom
--
--  [RUUVITAGS]
--    ruuvitag_0c90_humidity → House / Korvausilma tulo vallox / Livingroom
--    ruuvitag_0c90_pressure → House / Korvausilma tulo vallox / Livingroom
--    ruuvitag_ad37_pressure → House / Insulate middle top / Roof insulation
--    ruuvitag_ad37_humidity → House / Insulate middle top / Roof insulation
--    ruuvitag_81dd_pressure → House / Insulate N top / Roof insulation
--    ruuvitag_386c_humidity → House / on prem inside east / Spa
--    ruuvitag_396d_humidity → House / Under the house SE / Subfloor insulation
--
--  [WEATHER STATIONS]
--    weather_station_2_pressure → Cottage / East window on table / Entertainmentroom
--    weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent →
--       Cottage / East window on floor / Entertainmentroom
-- ===============================================================
--  MODE SWITCH:
--    - Default: populate all values every run (ensures consistency)
--    - Optional: Uncomment WHERE clause section for "only if empty"
-- ===============================================================

UPDATE sensor
SET
  room = CASE
    WHEN name LIKE '%iphone%' OR name LIKE '%ipad_%' THEN 'mobile device'
    WHEN name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Server room'

    WHEN name = 'outlet_2_power' THEN 'Spa'
    WHEN name = 'outlet_4_power' THEN 'Kitchen'
    WHEN name = 'outlet_6_power' THEN 'Spa'
    WHEN name = 'outlet_7_power' THEN 'Kitchen'
    WHEN name = 'outlet_9_power' THEN 'Kitchen'
    WHEN name = 'outlet_10_power' THEN 'Livingroom'
    WHEN name = 'outlet_11_power' THEN 'Livingroom'
    WHEN name = 'outlet_12_power' THEN 'Livingroom'
    WHEN name = 'outlet_13_power' THEN 'Livingroom'

    WHEN name = 'ruuvitag_0c90_humidity' THEN 'Livingroom'
    WHEN name = 'ruuvitag_0c90_pressure' THEN 'Livingroom'
    WHEN name = 'ruuvitag_ad37_pressure' THEN 'Roof insulation'
    WHEN name = 'ruuvitag_ad37_humidity' THEN 'Roof insulation'
    WHEN name = 'ruuvitag_81dd_pressure' THEN 'Roof insulation'
    WHEN name = 'ruuvitag_386c_humidity' THEN 'Spa'
    WHEN name = 'ruuvitag_396d_humidity' THEN 'Subfloor insulation'

    WHEN name = 'weather_station_2_pressure' THEN 'Entertainmentroom'
    WHEN name = 'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent' THEN 'Entertainmentroom'
    ELSE room
  END,

  precise_location = CASE
    WHEN name LIKE '%iphone%' OR name LIKE '%ipad_%' THEN 'mobile device'
    WHEN name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Server rack'

    WHEN name = 'outlet_2_power' THEN 'Between East, Windows'
    WHEN name = 'outlet_4_power' THEN 'East South Corner'
    WHEN name = 'outlet_6_power' THEN 'Left From South Windows'
    WHEN name = 'outlet_7_power' THEN 'Middle of South Windows'
    WHEN name = 'outlet_9_power' THEN 'Left From West Door'
    WHEN name = 'outlet_10_power' THEN 'Rightmost Next to AC Power'
    WHEN name = 'outlet_11_power' THEN 'Leftmost Next To AC Power'
    WHEN name = 'outlet_12_power' THEN 'Leftmost Up In Staircase'
    WHEN name = 'outlet_13_power' THEN 'Rightmost Up In Staricase'

    WHEN name = 'ruuvitag_0c90_humidity' THEN 'Korvausilma tulo vallox'
    WHEN name = 'ruuvitag_0c90_pressure' THEN 'Korvausilma tulo vallox'
    WHEN name = 'ruuvitag_ad37_pressure' THEN 'Insulate middle top'
    WHEN name = 'ruuvitag_ad37_humidity' THEN 'Insulate middle top'
    WHEN name = 'ruuvitag_81dd_pressure' THEN 'Insulate N top'
    WHEN name = 'ruuvitag_386c_humidity' THEN 'on prem inside east'
    WHEN name = 'ruuvitag_396d_humidity' THEN 'Under the house SE'

    WHEN name = 'weather_station_2_pressure' THEN 'East window on table'
    WHEN name = 'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent' THEN 'East window on floor'
    ELSE precise_location
  END,

  location = CASE
    WHEN name LIKE '%iphone%' OR name LIKE '%ipad_%' THEN 'mobile device'
    WHEN name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Livingroom'

    WHEN name IN (
      'outlet_2_power', 'outlet_4_power', 'outlet_6_power', 'outlet_7_power',
      'outlet_9_power', 'outlet_10_power', 'outlet_11_power', 'outlet_12_power', 'outlet_13_power',
      'ruuvitag_0c90_humidity', 'ruuvitag_0c90_pressure', 'ruuvitag_ad37_pressure',
      'ruuvitag_ad37_humidity', 'ruuvitag_81dd_pressure', 'ruuvitag_386c_humidity',
      'ruuvitag_396d_humidity'
    ) THEN 'House'

    WHEN name IN (
      'weather_station_2_pressure',
      'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
    ) THEN 'Cottage'

    ELSE location
  END

-- ===============================================================
-- OPTIONAL: enable this WHERE clause for “update only if empty”
-- ===============================================================
-- WHERE
--   (room IS NULL OR TRIM(room) = '' OR
--    precise_location IS NULL OR TRIM(precise_location) = '' OR
--    location IS NULL OR TRIM(location) = '');
-- ===============================================================

;

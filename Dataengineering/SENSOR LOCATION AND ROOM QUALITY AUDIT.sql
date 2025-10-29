USE smarthome;

-- ===============================================================
--  VIEW: vw_sensor_quality_audit
-- ===============================================================
--  Purpose:
--    Detects sensors whose (location, precise_location, room)
--    do NOT match the expected rule-based mappings, and
--    calculates a quality score (0–100%) per sensor.
--
--  Usage:
--    SELECT * FROM vw_sensor_quality_audit;
--
--  Interpretation:
--    quality_score = 100 → all match
--    quality_score = 67  → one mismatch
--    quality_score = 33  → two mismatches
--    quality_score = 0   → all mismatched
--
-- ===============================================================

CREATE OR REPLACE VIEW vw_sensor_quality_audit AS
SELECT
  name,
  location AS current_location,
  precise_location AS current_precise_location,
  room AS current_room,

  -- Expected values
  CASE
    WHEN name LIKE '%iphone%' OR name LIKE '%ipad_%' THEN 'mobile device'
    WHEN name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Livingroom'
    WHEN name IN (
      'outlet_2_power', 'outlet_4_power', 'outlet_6_power', 'outlet_7_power',
      'outlet_9_power', 'outlet_10_power', 'outlet_11_power',
      'outlet_12_power', 'outlet_13_power',
      'ruuvitag_0c90_humidity', 'ruuvitag_0c90_pressure',
      'ruuvitag_ad37_pressure', 'ruuvitag_ad37_humidity',
      'ruuvitag_81dd_pressure', 'ruuvitag_386c_humidity',
      'ruuvitag_396d_humidity'
    ) THEN 'House'
    WHEN name IN (
      'weather_station_2_pressure',
      'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
    ) THEN 'Cottage'
    ELSE NULL
  END AS expected_location,

  CASE
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
    WHEN name = 'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
      THEN 'East window on floor'
    ELSE NULL
  END AS expected_precise_location,

  CASE
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
    WHEN name = 'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
      THEN 'Entertainmentroom'
    ELSE NULL
  END AS expected_room,

  -- Mismatch flags
  CASE WHEN TRIM(IFNULL(location, '')) <> TRIM(IFNULL(
    CASE
      WHEN name LIKE '%iphone%' OR name LIKE '%ipad_%' THEN 'mobile device'
      WHEN name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Livingroom'
      WHEN name IN (
        'outlet_2_power','outlet_4_power','outlet_6_power','outlet_7_power',
        'outlet_9_power','outlet_10_power','outlet_11_power','outlet_12_power',
        'outlet_13_power','ruuvitag_0c90_humidity','ruuvitag_0c90_pressure',
        'ruuvitag_ad37_pressure','ruuvitag_ad37_humidity','ruuvitag_81dd_pressure',
        'ruuvitag_386c_humidity','ruuvitag_396d_humidity'
      ) THEN 'House'
      WHEN name IN (
        'weather_station_2_pressure',
        'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
      ) THEN 'Cottage'
      ELSE location
    END, '')
  ) THEN 'Mismatch' ELSE '' END AS location_mismatch,

  CASE WHEN TRIM(IFNULL(precise_location, '')) <> TRIM(IFNULL(
    CASE
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
      WHEN name = 'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
        THEN 'East window on floor'
      ELSE precise_location
    END, '')
  ) THEN 'Mismatch' ELSE '' END AS precise_location_mismatch,

  CASE WHEN TRIM(IFNULL(room, '')) <> TRIM(IFNULL(
    CASE
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
      WHEN name = 'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
        THEN 'Entertainmentroom'
      ELSE room
    END, '')
  ) THEN 'Mismatch' ELSE '' END AS room_mismatch,

  -- Quality score calculation (3 fields total)
  ROUND(
    (
      (CASE WHEN location_mismatch = '' THEN 1 ELSE 0 END) +
      (CASE WHEN precise_location_mismatch = '' THEN 1 ELSE 0 END) +
      (CASE WHEN room_mismatch = '' THEN 1 ELSE 0 END)
    ) / 3 * 100,
    0
  ) AS quality_score,

  CASE
    WHEN (
      (CASE WHEN location_mismatch = '' THEN 1 ELSE 0 END) +
      (CASE WHEN precise_location_mismatch = '' THEN 1 ELSE 0 END) +
      (CASE WHEN room_mismatch = '' THEN 1 ELSE 0 END)
    ) = 3 THEN 'Perfect'
    WHEN (
      (CASE WHEN location_mismatch = '' THEN 1 ELSE 0 END) +
      (CASE WHEN precise_location_mismatch = '' THEN 1 ELSE 0 END) +
      (CASE WHEN room_mismatch = '' THEN 1 ELSE 0 END)
    ) = 2 THEN 'Minor issues'
    ELSE 'Needs review'
  END AS quality_status

FROM sensor;

CREATE OR REPLACE VIEW vw_sensor_quality_audit AS
SELECT
  q.name,
  q.current_location,
  q.current_precise_location,
  q.current_room,
  q.expected_location,
  q.expected_precise_location,
  q.expected_room,
  q.location_mismatch,
  q.precise_location_mismatch,
  q.room_mismatch,

  ROUND(
    (
      (CASE WHEN q.location_mismatch = '' THEN 1 ELSE 0 END) +
      (CASE WHEN q.precise_location_mismatch = '' THEN 1 ELSE 0 END) +
      (CASE WHEN q.room_mismatch = '' THEN 1 ELSE 0 END)
    ) / 3 * 100,
    0
  ) AS quality_score,

  CASE
    WHEN q.location_mismatch = '' AND q.precise_location_mismatch = '' AND q.room_mismatch = '' THEN 'Perfect'
    WHEN (
      (CASE WHEN q.location_mismatch = '' THEN 1 ELSE 0 END) +
      (CASE WHEN q.precise_location_mismatch = '' THEN 1 ELSE 0 END) +
      (CASE WHEN q.room_mismatch = '' THEN 1 ELSE 0 END)
    ) = 2 THEN 'Minor issues'
    ELSE 'Needs review'
  END AS quality_status

FROM (
  SELECT
    s.name,
    s.location AS current_location,
    s.precise_location AS current_precise_location,
    s.room AS current_room,

    /* Expected values */
    CASE
      WHEN s.name LIKE '%iphone%' OR s.name LIKE '%ipad_%' THEN 'mobile device'
      WHEN s.name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Livingroom'
      WHEN s.name IN (
        'outlet_2_power','outlet_4_power','outlet_6_power','outlet_7_power',
        'outlet_9_power','outlet_10_power','outlet_11_power','outlet_12_power','outlet_13_power',
        'ruuvitag_0c90_humidity','ruuvitag_0c90_pressure','ruuvitag_ad37_pressure',
        'ruuvitag_ad37_humidity','ruuvitag_81dd_pressure','ruuvitag_386c_humidity','ruuvitag_396d_humidity'
      ) THEN 'House'
      WHEN s.name IN (
        'weather_station_2_pressure',
        'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
      ) THEN 'Cottage'
      ELSE NULL
    END AS expected_location,

    CASE
      WHEN s.name LIKE '%iphone%' OR s.name LIKE '%ipad_%' THEN 'mobile device'
      WHEN s.name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Server rack'
      WHEN s.name = 'outlet_2_power' THEN 'Between East, Windows'
      WHEN s.name = 'outlet_4_power' THEN 'East South Corner'
      WHEN s.name = 'outlet_6_power' THEN 'Left From South Windows'
      WHEN s.name = 'outlet_7_power' THEN 'Middle of South Windows'
      WHEN s.name = 'outlet_9_power' THEN 'Left From West Door'
      WHEN s.name = 'outlet_10_power' THEN 'Rightmost Next to AC Power'
      WHEN s.name = 'outlet_11_power' THEN 'Leftmost Next To AC Power'
      WHEN s.name = 'outlet_12_power' THEN 'Leftmost Up In Staircase'
      WHEN s.name = 'outlet_13_power' THEN 'Rightmost Up In Staricase'
      WHEN s.name = 'ruuvitag_0c90_humidity' THEN 'Korvausilma tulo vallox'
      WHEN s.name = 'ruuvitag_0c90_pressure' THEN 'Korvausilma tulo vallox'
      WHEN s.name = 'ruuvitag_ad37_pressure' THEN 'Insulate middle top'
      WHEN s.name = 'ruuvitag_ad37_humidity' THEN 'Insulate middle top'
      WHEN s.name = 'ruuvitag_81dd_pressure' THEN 'Insulate N top'
      WHEN s.name = 'ruuvitag_386c_humidity' THEN 'on prem inside east'
      WHEN s.name = 'ruuvitag_396d_humidity' THEN 'Under the house SE'
      WHEN s.name = 'weather_station_2_pressure' THEN 'East window on table'
      WHEN s.name = 'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
           THEN 'East window on floor'
      ELSE NULL
    END AS expected_precise_location,

    CASE
      WHEN s.name LIKE '%iphone%' OR s.name LIKE '%ipad_%' THEN 'mobile device'
      WHEN s.name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Server room'
      WHEN s.name = 'outlet_2_power' THEN 'Spa'
      WHEN s.name = 'outlet_4_power' THEN 'Kitchen'
      WHEN s.name = 'outlet_6_power' THEN 'Spa'
      WHEN s.name = 'outlet_7_power' THEN 'Kitchen'
      WHEN s.name = 'outlet_9_power' THEN 'Kitchen'
      WHEN s.name = 'outlet_10_power' THEN 'Livingroom'
      WHEN s.name = 'outlet_11_power' THEN 'Livingroom'
      WHEN s.name = 'outlet_12_power' THEN 'Livingroom'
      WHEN s.name = 'outlet_13_power' THEN 'Livingroom'
      WHEN s.name = 'ruuvitag_0c90_humidity' THEN 'Livingroom'
      WHEN s.name = 'ruuvitag_0c90_pressure' THEN 'Livingroom'
      WHEN s.name = 'ruuvitag_ad37_pressure' THEN 'Roof insulation'
      WHEN s.name = 'ruuvitag_ad37_humidity' THEN 'Roof insulation'
      WHEN s.name = 'ruuvitag_81dd_pressure' THEN 'Roof insulation'
      WHEN s.name = 'ruuvitag_386c_humidity' THEN 'Spa'
      WHEN s.name = 'ruuvitag_396d_humidity' THEN 'Subfloor insulation'
      WHEN s.name = 'weather_station_2_pressure' THEN 'Entertainmentroom'
      WHEN s.name = 'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
           THEN 'Entertainmentroom'
      ELSE NULL
    END AS expected_room,

    /* Mismatch flags */
    CASE WHEN TRIM(IFNULL(s.location,'')) <> TRIM(IFNULL(
      CASE
        WHEN s.name LIKE '%iphone%' OR s.name LIKE '%ipad_%' THEN 'mobile device'
        WHEN s.name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Livingroom'
        WHEN s.name IN (
          'outlet_2_power','outlet_4_power','outlet_6_power','outlet_7_power',
          'outlet_9_power','outlet_10_power','outlet_11_power','outlet_12_power',
          'outlet_13_power','ruuvitag_0c90_humidity','ruuvitag_0c90_pressure',
          'ruuvitag_ad37_pressure','ruuvitag_ad37_humidity','ruuvitag_81dd_pressure',
          'ruuvitag_386c_humidity','ruuvitag_396d_humidity'
        ) THEN 'House'
        WHEN s.name IN (
          'weather_station_2_pressure',
          'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
        ) THEN 'Cottage'
        ELSE s.location
      END, '')
    ) THEN 'Mismatch' ELSE '' END AS location_mismatch,

    CASE WHEN TRIM(IFNULL(s.precise_location,'')) <> TRIM(IFNULL(
      CASE
        WHEN s.name LIKE '%iphone%' OR s.name LIKE '%ipad_%' THEN 'mobile device'
        WHEN s.name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Server rack'
        WHEN s.name = 'outlet_2_power' THEN 'Between East, Windows'
        WHEN s.name = 'outlet_4_power' THEN 'East South Corner'
        WHEN s.name = 'outlet_6_power' THEN 'Left From South Windows'
        WHEN s.name = 'outlet_7_power' THEN 'Middle of South Windows'
        WHEN s.name = 'outlet_9_power' THEN 'Left From West Door'
        WHEN s.name = 'outlet_10_power' THEN 'Rightmost Next to AC Power'
        WHEN s.name = 'outlet_11_power' THEN 'Leftmost Next To AC Power'
        WHEN s.name = 'outlet_12_power' THEN 'Leftmost Up In Staircase'
        WHEN s.name = 'outlet_13_power' THEN 'Rightmost Up In Staricase'
        WHEN s.name = 'ruuvitag_0c90_humidity' THEN 'Korvausilma tulo vallox'
        WHEN s.name = 'ruuvitag_0c90_pressure' THEN 'Korvausilma tulo vallox'
        WHEN s.name = 'ruuvitag_ad37_pressure' THEN 'Insulate middle top'
        WHEN s.name = 'ruuvitag_ad37_humidity' THEN 'Insulate middle top'
        WHEN s.name = 'ruuvitag_81dd_pressure' THEN 'Insulate N top'
        WHEN s.name = 'ruuvitag_386c_humidity' THEN 'on prem inside east'
        WHEN s.name = 'ruuvitag_396d_humidity' THEN 'Under the house SE'
        WHEN s.name = 'weather_station_2_pressure' THEN 'East window on table'
        WHEN s.name = 'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
             THEN 'East window on floor'
        ELSE s.precise_location
      END, '')
    ) THEN 'Mismatch' ELSE '' END AS precise_location_mismatch,

    CASE WHEN TRIM(IFNULL(s.room,'')) <> TRIM(IFNULL(
      CASE
        WHEN s.name LIKE '%iphone%' OR s.name LIKE '%ipad_%' THEN 'mobile device'
        WHEN s.name LIKE '%arvopaukkunen_arvohomeassistant%' THEN 'Server room'
        WHEN s.name = 'outlet_2_power' THEN 'Spa'
        WHEN s.name = 'outlet_4_power' THEN 'Kitchen'
        WHEN s.name = 'outlet_6_power' THEN 'Spa'
        WHEN s.name = 'outlet_7_power' THEN 'Kitchen'
        WHEN s.name = 'outlet_9_power' THEN 'Kitchen'
        WHEN s.name = 'outlet_10_power' THEN 'Livingroom'
        WHEN s.name = 'outlet_11_power' THEN 'Livingroom'
        WHEN s.name = 'outlet_12_power' THEN 'Livingroom'
        WHEN s.name = 'outlet_13_power' THEN 'Livingroom'
        WHEN s.name = 'ruuvitag_0c90_humidity' THEN 'Livingroom'
        WHEN s.name = 'ruuvitag_0c90_pressure' THEN 'Livingroom'
        WHEN s.name = 'ruuvitag_ad37_pressure' THEN 'Roof insulation'
        WHEN s.name = 'ruuvitag_ad37_humidity' THEN 'Roof insulation'
        WHEN s.name = 'ruuvitag_81dd_pressure' THEN 'Roof insulation'
        WHEN s.name = 'ruuvitag_386c_humidity' THEN 'Spa'
        WHEN s.name = 'ruuvitag_396d_humidity' THEN 'Subfloor insulation'
        WHEN s.name = 'weather_station_2_pressure' THEN 'Entertainmentroom'
        WHEN s.name = 'weather_station_2_weather_station_2_weather_station_2_kivikangas1_out_battery_percent'
             THEN 'Entertainmentroom'
        ELSE s.room
      END, '')
    ) THEN 'Mismatch' ELSE '' END AS room_mismatch

  FROM sensor s
) AS q;

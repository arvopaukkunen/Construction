#NodeRed with Cerbo OS large
Logic here would be responsible for transferring from victron based data directly to local Influxdb v2 - without any outside network connection.  Navively same information and more, is transferred to the Victron cloud for full remote control - secured only with usernames and passwords. That is not mandatory, but it's nice to have - build in - feature. It can be turned off from remote console by de activating victron world connections.

If victron remote capabilities are turned off, the MQTT & MODBUS are still usable inside local network, but below is flow based data integration extract, transform and load (ETL) functionality. Data is usable for Influx, Grafana and Homeassistant dashboard.

##This is base minimum local data transformation done by NodeRed.
![Alt text](image.png)
![Alt text](image-1.png)


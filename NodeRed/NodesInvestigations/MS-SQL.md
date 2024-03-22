var Dimdatetime = new Date(),
dformat = [Dimdatetime.getMonth() + 1,
    Dimdatetime.getDate(),
    Dimdatetime.getDay(),
    Dimdatetime.getFullYear()].join('/') + ' ' +
    [Dimdatetime.getHours(),
    Dimdatetime.getMinutes(),
    Dimdatetime.getSeconds()].join(':');
var name = msg.payload[0];
var value = msg.payload[1];
var description = msg.payload[2];
var measure_type = msg.payload[3];
var status = msg.payload[4];
var DatabaseSQL = "insert into [prod_smarthome].[sensor_ai] values('" + name + "', " + value + ", '" + description + "', '" + measure_type + "', '" + status + "', '" + dformat + "')"

return {payload : DatabaseSQL};
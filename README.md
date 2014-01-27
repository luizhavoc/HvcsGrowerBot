HvcsGrowerBot
=============
Usage:

Just put your xively Api Key and Feed Id on the agent code on IDE designed fields:

const XIVELY_API_KEY = "fill info here";
const XIVELY_FEED_ID = "fill info here";


this code will automatically opens the xively channel with the ID filled on this lines on the agent code:

const XIVELYCHANNEL1 = "Temperature";
const XIVELYCHANNEL2 = "Light";
const XIVELYCHANNEL3 = "Soil";
const XIVELYCHANNEL4 = "AirHumidity";

In my case my primary language is portuguese so I use:

const XIVELYCHANNEL1 = "Temperatura";
const XIVELYCHANNEL2 = "Luz";
const XIVELYCHANNEL3 = "AguaSolo";
const XIVELYCHANNEL4 = "HumidadeRelativaAr";


To implement in the future:
- httpHandler to display data on "read" request
- Update arduinosketch through Imp as this board do not have a USB connection

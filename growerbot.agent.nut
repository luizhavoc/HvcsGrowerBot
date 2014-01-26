//Growerbot code by Havoc (luizhavoc@gmail.com)
//thanks tombrew, this code is based on https://github.com/electricimp/examples/tree/master/tempBug
//thanks jwehr @ http://forums.electricimp.com/ for all the help debugging and adding to the code.

/* GLOBALS and CONSTANTS -----------------------------------------------------*/

const XIVELY_API_KEY = "fill info here";
const XIVELY_FEED_ID = "fill info here";
const XIVELYCHANNEL1 = "Temperature";
const XIVELYCHANNEL2 = "Light";
const XIVELYCHANNEL3 = "Soil";
const XIVELYCHANNEL4 = "AirHumidity";
Xively <- {};  // this makes a 'namespace'

/* CLASS AND GLOBAL FUNCTION DEFINITIONS -------------------------------------*/

// Xively "library". See https://github.com/electricimp/reference/tree/master/webservices/xively

class Xively.Client {
    ApiKey = null;
    triggers = [];

  constructor(apiKey) {
  	this.ApiKey = apiKey;
	}
	
	/*****************************************
	 * method: PUT
	 * IN:
	 *   feed: a XivelyFeed we are pushing to
	 *   ApiKey: Your Xively API Key
	 * OUT:
	 *   HttpResponse object from Xively
	 *   200 and no body is success
	 *****************************************/
	function Put(feed){
		local url = "https://api.xively.com/v2/feeds/" + feed.FeedID + ".json";
		local headers = { "X-ApiKey" : ApiKey, "Content-Type":"application/json", "User-Agent" : "Xively-Imp-Lib/1.0" };
		local request = http.put(url, headers, feed.ToJson());

		return request.sendsync();
	}
	
	/*****************************************
	 * method: GET
	 * IN:
	 *   feed: a XivelyFeed we fulling from
	 *   ApiKey: Your Xively API Key
	 * OUT:
	 *   An updated XivelyFeed object on success
	 *   null on failure
	 *****************************************/
	function Get(feed){
		local url = "https://api.xively.com/v2/feeds/" + feed.FeedID + ".json";
		local headers = { "X-ApiKey" : ApiKey, "User-Agent" : "xively-Imp-Lib/1.0" };
		local request = http.get(url, headers);
		local response = request.sendsync();
		if(response.statuscode != 200) {
			server.log("error sending message: " + response.body);
			return null;
		}
	
		local channel = http.jsondecode(response.body);
		for (local i = 0; i < channel.datastreams.len(); i++)
		{
			for (local j = 0; j < feed.Channels.len(); j++)
			{
				if (channel.datastreams[i].id == feed.Channels[j].id)
				{
					feed.Channels[j].current_value = channel.datastreams[i].current_value;
					break;
				}
			}
		}
	
		return feed;
	}

}
    
class Xively.Feed{
    FeedID = null;
    Channels = null;
    
    constructor(feedID, channels)
    {
        this.FeedID = feedID;
        this.Channels = channels;
    }
    
    function GetFeedID() { return FeedID; }

    function ToJson()
    {
        local json = "{ \"datastreams\": [";
        for (local i = 0; i < this.Channels.len(); i++)
        {
            json += this.Channels[i].ToJson();
            if (i < this.Channels.len() - 1) json += ",";
        }
        json += "] }";
        return json;
    }
}

class Xively.Channel {
    id = null;
    current_value = null;
    
    constructor(_id)
    {
        this.id = _id;
    }
    
    function Set(value) { 
    	this.current_value = value; 
    }
    
    function Get() { 
    	return this.current_value; 
    }
    
    function ToJson() { 
    	return http.jsonencode({id = this.id, current_value = this.current_value }); 
    }
}

function postToXively(data, channel) {
    xivelyChannel <- Xively.Channel(channel);
    xivelyChannel.Set(data);
    xivelyFeed <- Xively.Feed(XIVELY_FEED_ID, [xivelyChannel]);
    local resp = xivelyClient.Put(xivelyFeed);
    server.log("Posted to Xively: "+data+", got return code: "+resp.statuscode+", msg: "+resp.body);
}

/* REGISTER DEVICE CALLBACKS  ------------------------------------------------*/
//this catches data sent from device
device.on("temp", function(temp) {
  //server.log(temp)
  postToXively(temp, XIVELYCHANNEL1);
});

device.on("lux", function(lux) {
  //server.log(lux)
  postToXively(lux, XIVELYCHANNEL2);
});

device.on("soil", function(soil) {
  //server.log(soil)
  postToXively(soil, XIVELYCHANNEL3);
});

device.on("humid", function(humid) {
  //server.log(humid)
  postToXively(humid, XIVELYCHANNEL4);
});
/* RUNTIME BEGINS HERE -------------------------------------------------------*/

server.log("Agent ready for work!");

// instantiate our Xively client
xivelyClient <- Xively.Client(XIVELY_API_KEY);

//Display sensor data on Agent URL
function httpHandler (req, resp) {
  server.log("Agent got a request");
  resp.send(200, "Temp:" + "Light:" + "Soil:" + "Air Humidity:");
}
http.onrequest(httpHandler);

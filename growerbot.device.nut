//Growerbot code by Havoc (luizhavoc@gmail.com)
//thanks to https://github.com/liseman for parts of the code
//thanks jwehr @ http://forums.electricimp.com/ for all the help debugging and adding to the code.

  
// This is for time measurement: local time with hardware.micros
local starttime = hardware.micros();
//uart initialization
function startUART()
{
    hardware.configure(UART_1289);
    hardware.uart1289.configure(2400, 8, PARITY_NONE, 1, NO_CTSRTS);     //baud:19200, dataBits:8, parity, stopbit
}
//uart check
function checkUART(){
    imp.wakeup(60, checkUART);
    local c = "";
    local b = hardware.uart1289.read();

    while (b != -1) 
    {
    c += b.tochar();
    b = hardware.uart1289.read();
    }

  if (c.len()){
    //this splits the string sent by arduino into individual sensors and logs them throug server.log
    //TEMPERATURE info from arduino data
    local tStart = c.find("T");
    tStart = tStart + 1;
    local temp = c.slice(tStart);
    local tEnd = temp.find("T");
    temp = temp.slice(0,tEnd);
    server.log("Temp:" + temp + "°C");
    //find location of L in sensor data string
    local lStart = c.find("L");
    lStart = lStart + 1;
    local light = c.slice(lStart);
    local lEnd = light.find("L");
    light = light.slice(0,lEnd);
    server.log("Light:" + light + "lx");
    //find location of M(soil) in sensor data string
    local mStart = c.find("M");
    mStart = mStart + 1;
    local soil = c.slice(mStart);
    local mEnd = soil.find("M");
    soil = soil.slice(0,mEnd);
    server.log("Soil:" + soil); // implement a SI for this variable http://en.wikipedia.org/wiki/Soil_resistivity
    //find location of Humidity in sensor data string
    local hStart = c.find("H");
    hStart = hStart + 1;
    local humid = c.slice(hStart);
    
    local hEnd = humid.find("H");
    humid = humid.slice(0,hEnd);
    server.log("Hum:" + humid + "%");
//this sends each sensor value to agent agent catches this through device.on command
agent.send("temp", temp);
agent.send("lux", light);
agent.send("soil", soil);
agent.send("humid", humid);
} // if bracket end
} //checkUART bracket end

startUART();    //setup uart
checkUART();    //begin uart polling
// overall runtime calculation
local timestampoverall = hardware.micros();
server.log(format("Read cycle took %d us", (timestampoverall-starttime)));


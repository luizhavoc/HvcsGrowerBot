//Growerbot code by Havoc (luizhavoc@gmail.com)
//thanks to https://github.com/liseman for parts of the code
//thanks jwehr @ http://forums.electricimp.com/ for all the help debugging and adding to the code.

  
// This is for time measurement: local time with hardware.micros
local starttime = hardware.micros();
//uart initialization
function startUART()
{
    hardware.configure(UART_1289);
    hardware.uart1289.configure(2400, 8, PARITY_NONE, 1, NO_CTSRTS);     //baud:2400, dataBits:8, parity, stopbit
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

agent.on("agua", function (value) {
  if (value == "0") hardware.uart1289.write("Pp0\n") // if 0 was passed in, turn relay 1 off
  else hardware.uart1289.write("Pp1\n");            // otherwise, turn it on
});
agent.on("luz", function (value) {
  if (value == "0") hardware.uart1289.write("Ll0\n") // if 0 was passed in, turn relay 2 off
  else hardware.uart1289.write("Ll1\n");            // otherwise, turn it on
});
agent.on("targetluz", function (value) {
  local targetnumber = value
  hardware.uart1289.write("B" + value + "B\n") // 
});
agent.on("targetsolo", function (value) {
  local targetnumber = value
  hardware.uart1289.write("M" + value + "M\n") // 
});
agent.on("targetprop", function (value) {
  local targetnumber = value
  hardware.uart1289.write("L" + value + "L\n") // 
});

startUART();    //setup uart
checkUART();    //begin uart polling
// overall runtime calculation
local timestampoverall = hardware.micros();
server.log(format("Read cycle took %d us", (timestampoverall-starttime)));


/*
The MIT License (MIT)

Copyright (c) 2013 Electric Imp

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

server.log("Device started, impee_id " + hardware.getimpeeid() + " and mac = " + imp.getmacaddress() );

//------------------------------------------------------------------------------------------------------------------------------

// Drive pin1 high for reset
RESET <- hardware.pin1;
RESET.configure(DIGITAL_OUT);
RESET.write(0);

// Sequence number
__seq <- 0x28;


//------------------------------------------------------------------------------------------------------------------------------
/* STK500 constants list, from AVRDUDE */
const MESSAGE_START       = 0x1B;
const TOKEN               = 0x0E;
const STK_OK              = 0x10;
const STK_FAILED          = 0x11;  // Not used
const STK_UNKNOWN         = 0x12;  // Not used
const STK_NODEVICE        = 0x13;  // Not used
const STK_INSYNC          = 0x14;  // ' '
const STK_NOSYNC          = 0x15;  // Not used
const ADC_CHANNEL_ERROR   = 0x16;  // Not used
const ADC_MEASURE_OK      = 0x17;  // Not used
const PWM_CHANNEL_ERROR   = 0x18;  // Not used
const PWM_ADJUST_OK       = 0x19;  // Not used
const CRC_EOP             = 0x20;  // 'SPACE'
const STK_GET_SYNC        = 0x30;  // '0'
const STK_GET_SIGN_ON     = 0x31;  // '1'
const STK_SET_PARAMETER   = 0x40;  // '@'
const STK_GET_PARAMETER   = 0x41;  // 'A'
const STK_SET_DEVICE      = 0x42;  // 'B'
const STK_SET_DEVICE_EXT  = 0x45;  // 'E'
const STK_ENTER_PROGMODE  = 0x50;  // 'P'
const STK_LEAVE_PROGMODE  = 0x51;  // 'Q'
const STK_CHIP_ERASE      = 0x52;  // 'R'
const STK_CHECK_AUTOINC   = 0x53;  // 'S'
const STK_LOAD_ADDRESS    = 0x55;  // 'U'
const STK_UNIVERSAL       = 0x56;  // 'V'
const STK_PROG_FLASH      = 0x60;  // '`'
const STK_PROG_DATA       = 0x61;  // 'a'
const STK_PROG_FUSE       = 0x62;  // 'b'
const STK_PROG_LOCK       = 0x63;  // 'c'
const STK_PROG_PAGE       = 0x64;  // 'd'
const STK_PROG_FUSE_EXT   = 0x65;  // 'e'
const STK_READ_FLASH      = 0x70; // 'p'
const STK_READ_DATA       = 0x71;  // 'q'
const STK_READ_FUSE       = 0x72;  // 'r'
const STK_READ_LOCK       = 0x73;  // 's'
const STK_READ_PAGE       = 0x74;  // 't'
const STK_READ_SIGN       = 0x75;  // 'u'
const STK_READ_OSCCAL     = 0x76;  // 'v'
const STK_READ_FUSE_EXT   = 0x77;  // 'w'
const STK_READ_OSCCAL_EXT = 0x78;  // 'x'


//------------------------------------------------------------------------------------------------------------------------------
function HEXDUMP(buf, len = null) {
    if (buf == null) return "null";
    if (len == null) {
        len = (typeof buf == "blob") ? buf.tell() : buf.len();
    }
    
    local dbg = "";
    for (local i = 0; i < len; i++) {
        local ch = buf[i];
        dbg += format("0x%02X ", ch);
    }
    
    return format("%s (%d bytes)", dbg, len)
}


//------------------------------------------------------------------------------------------------------------------------------
function SERIAL_READ(len = 100, timeout = 300) {
    
    local rxbuf = blob(len);
    local writen = rxbuf.writen.bindenv(rxbuf);
    local read = hardware.uart1289.read.bindenv(hardware.uart1289);
    local hw = hardware;
    local ms = hw.millis.bindenv(hw);
    local started = ms();
    
    // Clean up any extra bytes
    while (hardware.uart1289.read() != -1);
    
    if (rxbuf.tell() == 0) {
        return null;
    } else {
        return rxbuf;
    }
}


//------------------------------------------------------------------------------------------------------------------------------
function execute(command = null, param = null, response_length = 100, response_timeout = 300) {
    
    local send_buffer = null;
    if (command == null) {
        send_buffer = format("%c", CRC_EOP);
    } else if (param == null) {
        send_buffer = format("%c%c", command, CRC_EOP);
    } else if (typeof param == "array") {
        send_buffer = format("%c", command);
        foreach (datum in param) {
            switch (typeof datum) {
                case "string":
                case "blob":
                case "array":
                case "table":
                    foreach (adat in datum) {
                        send_buffer += format("%c", adat);
                    }
                    break;
                default:
                    send_buffer += format("%c", datum);
            }
        }
        send_buffer += format("%c", CRC_EOP);
    } else {
        send_buffer = format("%c%c%c", command, param, CRC_EOP);
    }
    
    // server.log("Sending: " + HEXDUMP(send_buffer));
    hardware.uart1289.write(send_buffer);
    
    local resp_buffer = SERIAL_READ(response_length+2, response_timeout);
    // server.log("Received: " + HEXDUMP(resp_buffer));
    
    assert(resp_buffer != null);
    assert(resp_buffer.tell() >= 2);
    assert(resp_buffer[0] == STK_INSYNC);
    assert(resp_buffer[resp_buffer.tell()-1] == STK_OK);
    
    local tell = resp_buffer.tell();
    if (tell == 2) return blob(0);
    resp_buffer.seek(1);
    return resp_buffer.readblob(tell-2);
}


//------------------------------------------------------------------------------------------------------------------------------
function check_duino() {
    // Clear the read buffer
    SERIAL_READ(); 

    // Check everything we can check to ensure we are speaking to the correct boot loader
    local major = execute(STK_GET_PARAMETER, 0x81, 1);
    local minor = execute(STK_GET_PARAMETER, 0x82, 1);
    local invalid = execute(STK_GET_PARAMETER, 0x83, 1);
    local signature = execute(STK_READ_SIGN);
    assert(major.len() == 1 && major[0] == 0x04);
    assert(minor.len() == 1 && minor[0] == 0x04);
    assert(invalid.len() == 1 && invalid[0] == 0x03);
    assert(signature.len() == 3 && signature[0] == 0x1E && signature[1] == 0x95 && signature[2] == 0x0F);
}


//------------------------------------------------------------------------------------------------------------------------------
function program_duino(address16, data) {

    local addr8_hi = (address16 >> 8) & 0xFF;
    local addr8_lo = address16 & 0xFF;
    local data_len = data.len();
    
    execute(STK_LOAD_ADDRESS, [addr8_lo, addr8_hi], 0);
    execute(STK_PROG_PAGE, [0x00, data_len, 0x46, data], 0)
    local data_check = execute(STK_READ_PAGE, [0x00, data_len, 0x46], data_len)
    
    assert(data_check.len() == data_len);
    for (local i = 0; i < data_len; i++) {
        assert(data_check[i] == data[i]);
    }

}


//------------------------------------------------------------------------------------------------------------------------------
function bounce(callback = null) {
    
    // Bounce the reset pin
    server.log("Bouncing the Arduino reset pin");
    local ACTIVITY = 0
    imp.wakeup(0.5, function() {
        RESET.write(1);
        imp.wakeup(0.2, function() {
            RESET.write(0);
            imp.wakeup(0.3, function() {
                check_duino();
                if (callback) callback();
            });
        });
    });
}

//------------------------------------------------------------------------------------------------------------------------------
function burn(program) {
    bounce(function() {
        server.log("Burning hex program to Arduino");
        foreach (line in program) {
            program_duino(line.addr, line.data);
        }
        // execute(STK_LEAVE_PROGMODE, null, 0);
        server.log("Done!")
        agent.send("done", true);
    
    })
}


//------------------------------------------------------------------------------------------------------------------------------
bounce(function() {
    agent.on("burn", burn);
    agent.send("ready", true);
})

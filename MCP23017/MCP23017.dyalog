:Class MCP23017
⍝ Dyalog APL class for MCP23017 16bit GPIO Expander
⍝
⍝ Dyalog APL port based on Adafruit Python library for MCP23x port expander
⍝ Written by Adafruit Industries. MIT license.
⍝
⍝∇:require =/../I2C/I2C.dyalog

    ⍝ Set environment
    ⎕IO←⎕ML←1

    ⍝ ----------------------------------------------------------------------
    ⍝ Debug
    DEBUG ← 0            ⍝ Debug Flag Off:0 On:1
    _LOG←{DEBUG:1 ⎕←⍵}   ⍝ Console log output if DEBUG

    ⍝ Member objects
    ⍝
    ⍝ IC2 bus device is attached to
    :Field Public I2CBus
    ⍝ Device address
    :Field Public DeviceAddress ← 32   ⍝ Default 0x20 (A0/A1/A2 set to low)

    ⍝ Local variables and constants
    ⍝
    ⍝ MCP23017 Register addresses
    IODIRA ← 0     ⍝ 0x00
    IODIRB ← 1     ⍝ 0x01
    GPIOA  ← 18    ⍝ 0x12
    GPIOB  ← 19    ⍝ 0x13
    GPPUA  ← 12    ⍝ 0x0C
    GPPUB  ← 13    ⍝ 0x0D
    OLATA  ← 20    ⍝ 0x14
    OLATB  ← 21    ⍝ 0x15
    ⍝ Input/Output definition
    INPUT  ← 1
    OUTPUT ← 0

    ⍝ DFNs
    ⍝
    ⍝ Decimal to boolean array
    _bool8  ←{(8⍴2)⊤⍵}   ⍝ Converts a decimal to a binary array of 8 bit
    _bool16 ←{(16⍴2)⊤⍵}  ⍝ Converts a decimal to a binary array of 16 bit
    ⍝ Boolean array to decimal
    _decimal←{2⊥⍵}       ⍝ Converts a arbitray binary to a decimal

    ⍝ Constructor methods
    ⍝
    ⍝ Device is initialized with a default I2C bus instance at address 32 (0x20)
    ∇ make0;r
      :Implements Constructor                                                                                                                                    
      :Access Public                                                                                                                                             
      I2CBus←⎕NEW #.I2C
      r←initializeI2CBus
      r←defaultConfiguration
    ∇
    ⍝ Device is initialized with a default I2C bus at the given address
    ∇ make1 address;r
      :Implements Constructor
      :Access Public
      I2CBus←⎕NEW #.I2C
      DeviceAddress←address
      r←initializeI2CBus
      r←defaultConfiguration
    ∇
    ⍝ Device is initialized with a given I2C bus an address
    ∇ make2(i2cbus address);r
      :Implements Constructor
      :Access Public
      I2CBus←i2cbus
      DeviceAddress←address
      r←initializeI2CBus
      r←defaultConfiguration
    ∇
    ⍝ Open I2C bus of this device
    ∇ r←initializeI2CBus
      r←I2CBus.OpenBus
      _LOG'MCP23017 at Bus:Address=',(1 0⍕I2CBus.getBusID),':',⍕DeviceAddress,'is now alive.'
    ∇
    ⍝ Set default configuration
    ∇ r←defaultConfiguration
      ⍝ All pins of PortA and PortB are inputs
      r←Config16 65535   ⍝ 0xFFFF
      ⍝ All pullups of PortA and PortB are On
      r←Pullup16 65535   ⍝ 0xFFFF
      _LOG'MCP23017 Default configuration set (All Input, Pullup ON).'
    ∇

    ⍝ Utility functions
    ⍝
    ⍝ Clear or set given bit in bitmap according value
    ⍝ value←0  Clear bit
    ⍝ value←1  Set bit
    ⍝ First bit (2*0) is indicated by bit←0
    ⍝ bitmap is a vector of booleans e.g. bitmap←0 0 0 1
    ∇ r←changebit(bitmap bit value)
      :If value=0
          r←bitmap∧(~bit⌽((⍴bitmap)⍴2)⊤1) ⍝ Clear given bit
      :Else
          r←bitmap∨(bit⌽((⍴bitmap)⍴2)⊤1)  ⍝ Set given bit
      :EndIf
    ∇

    ⍝ Register pin change methods
    ⍝
    ⍝ Change pin value of given register/port
    ⍝ port      : address of port/register
    ⍝ pin       : index of pin/bit to change (First bit (2*0) is indicated by pin←0)
    ⍝ value     : ←0 Clear bit, ←1 Set bit
    ∇ r←readandchangepin(port pin value);newvalue;funret;funerr
        ⍝ Read current value from port
      funret currvalue funerr←I2CBus.ReadBytes DeviceAddress port 0
        ⍝ If read was not successful return error information
        ⍝ otherwise change bit as instructed and return result
      :If funret≠0
          r←funret currvalue funerr
      :Else
          r←changepin port pin value currvalue
      :EndIf
    ∇
    ⍝ Change pin value of given register/port
    ⍝ port        : address of port/register
    ⍝ pin         : index of pin/bit to change (First bit (2*0) is indicated by pin←0)
    ⍝ value       : ←0 Clear bit, ←1 Set bit
    ⍝ currvalue   : value to apply change to
    ∇ r←changepin(port pin value currvalue);newvalue
        ⍝ Change bit
      newvalue←2⊥(changebit(_bool8 currvalue)pin value)
        ⍝ Write new value to port/register
      r←I2CBus.WriteBytes DeviceAddress port newvalue
    ∇

    ⍝ GPIO configuration methods
    ⍝
    ⍝ Configure GPIOA (8 bit)
    ∇ r←Config8 value
      :Access Public
        ⍝ Write 8 bit value to IODIRA
      r←I2CBus.WriteBytes DeviceAddress IODIRA value
    ∇
    ⍝ Configure GPIOA/B (16 bit)
    ∇ r←Config16 value;split
      :Access Public
        ⍝ Encode value into 2 byte array and change LSB/HSB
      split←1⌽256 256⊤value
        ⍝ Write 16 bit value to IODIRA/B
      r←I2CBus.WriteBytes DeviceAddress IODIRA split
    ∇
    ⍝ Configure a pin as Input/Output (single pin operation)
    ⍝ pin         : index of pin/bit to change (First bit (2*0) is indicated by pin←0)
    ⍝ mode        : ←0 Configure pin as output, ←1 ..as input
    ⍝ returnvalue : funret IODIR-Register IODIR-Pin-Value I2CErrCode
    ∇ r←Config(pin mode)
      :Access Public
        ⍝ If pin is > 7 the PortB needs to be configured
      :If pin<8
            ⍝ Configure addressed pin PortA
          r←readandchangepin IODIRA pin mode
      :Else
            ⍝ Configure addressed pin of PortB
          r←readandchangepin IODIRB(pin-8)mode
      :EndIf
    ∇

    ⍝ GPPU configuration methods
    ⍝
    ⍝ Configure GPPUA (8 bit)
    ∇ r←Pullup8 value
      :Access Public
        ⍝ Write 8 bit value to GPPUA
      r←I2CBus.WriteBytes DeviceAddress GPPUA value
    ∇
    ⍝ Configure GPIOA/B (16 bit)
    ∇ r←Pullup16 value;split
      :Access Public
        ⍝ Encode value into 2 byte array and change LSB/HSB
      split←1⌽256 256⊤value
        ⍝ Write 16 bit value to GPPUA/B
      r←I2CBus.WriteBytes DeviceAddress GPPUA split
    ∇
    ⍝ Configure pullup for a given pin (single pin operation)
    ⍝ pin         : index of pin/bit to change (First bit (2*0) is indicated by pin←0)
    ⍝ mode        : ←0 Pullup Off, ←1 ..On
    ⍝ returnvalue : funret GPPU-Register GPPU-Pin-Value I2CErrCode
    ∇ r←Pullup(pin mode)
      :Access Public
        ⍝ If pin is > 7 the Pullups for PortB need to be configured
      :If pin<8
            ⍝ Configure addressed pullup for PortA
          r←readandchangepin GPPUA pin mode
      :Else
            ⍝ Configure addressed pullup for PortB
          r←readandchangepin GPPUB(pin-8)mode
      :EndIf
    ∇

    ⍝ Generic write methods
    ⍝
    ⍝ Write Bytes to register
    ∇ r←WriteBytes(register value)
      :Access Public
        ⍝ Write given value(s) to register address
      r←I2CBus.WriteBytes DeviceAddress register value
    ∇

    ⍝ GPIO output methods
    ⍝
    ⍝ Write 8bit value to GPIOA
    ∇ r←Write8 value
      :Access Public
        ⍝ Write 8 bit value to GPIOA
      r←I2CBus.WriteBytes DeviceAddress OLATA value
    ∇
    ⍝ Write 16bit value to GPIOA/B
    ∇ r←Write16 value;split
      :Access Public
        ⍝ Encode value into 2 byte array and change LSB/HSB
      split←1⌽256 256⊤value
        ⍝ Write 16 bit value to GPIOA/B
      r←I2CBus.WriteBytes DeviceAddress OLATA split
    ∇
    ⍝ Output value to a GPIO Pin (single pin operation)
    ⍝ pin         : index of pin/bit to change (First bit (2*0) is indicated by pin←0)
    ⍝ value       : ←0 Set Pin to Low, ←1 ..to High
    ⍝ returnvalue : funret GPIO-Register GPIO-Value I2CErrCode
    ∇ r←Output(pin value)
      :Access Public
        ⍝ If pin is > 7 PortB needs to be addressed
      :If pin<8
            ⍝ Configure addressed pin PortA
          r←readandchangepin GPIOA pin value
      :Else
            ⍝ Configure addressed pin of PortB
          r←readandchangepin GPIOB(pin-8)value
      :EndIf
    ∇

    ⍝ Generic read methods
    ⍝
    ⍝ Read Bytes from register
    ∇ r←ReadBytes(register buffer)
      :Access Public
        ⍝ Read bytes from given register
      r←I2CBus.ReadBytes DeviceAddress register buffer
    ∇

    ⍝ GPIO input methods
    ⍝
    ⍝ Read 8 bit from latch register OLATA
    ∇ r←ReadU8;funret;funval;funerr
      :Access Public
        ⍝ Read 8 bit from latch register OLATA
      funret funval funerr←I2CBus.ReadBytes DeviceAddress OLATA 0
        ⍝ Return value as read
      r←funret funval funerr
    ∇
    ⍝ Read 8 bit (singned) from latch register OLATA
    ∇ r←ReadS8;funret;funval;funerr
      :Access Public
        ⍝ Read 8 bit from latch register OLATA
      funret funval funerr←I2CBus.ReadBytes DeviceAddress OLATA 0
        ⍝ Return signed value if value >= 128 (0x80)
      funval←((funval)(¯128+(funval-128)))[1+funval≥128]
      r←funret funval funerr
    ∇
    ⍝ Read 16 bit from latch register OLATA/OLATB
    ∇ r←ReadU16;funret;funval;funerr
      :Access Public
        ⍝ Read 16 bit from latch register OLATA/OLATB
      funret funval funerr←I2CBus.ReadBytes DeviceAddress OLATA(0 0)
        ⍝ Covert 2 byte array to 16 bit value (MSB switched)
      funval←(256)⊥1⌽funval
        ⍝ Return value as read
      r←funret funval funerr
    ∇
    ⍝ Read 16 bit (singned) from latch register OLATA/OLATB
    ∇ r←ReadS16;funret;funval;funerr
      :Access Public
        ⍝ Read 16 bit from latch register OLATA/OLATB
      funret funval funerr←I2CBus.ReadBytes DeviceAddress OLATA(0 0)
        ⍝ Covert 2 byte array to 16 bit value (MSB switched)
      funval←(256)⊥1⌽funval
        ⍝ Return signed value if value >= 32768 (0x8000)
      funval←((funval)(¯32768+(funval-32768)))[1+funval≥32768]
      r←funret funval funerr
    ∇
    ⍝ Read input value from a GPIO Pin (single pin operation)
    ⍝ pin         : index of pin/bit to get value for (First bit (2*0) is indicated by pin←0)
    ⍝ returnvalue : funret GPIO-PinValue I2CErrCode
    ∇ r←Input pin;funret;funval;funerr
      :Access Public
        ⍝ If pin is > 7 PortB needs to be addressed
      :If pin<8
            ⍝ Read PortA
          funret funval funerr←I2CBus.ReadBytes DeviceAddress OLATA 0
            ⍝ Boolean endcode read value and select pin
          funval←((8⍴2)⊤funval)[8-pin]
            ⍝ Build return value
          funval←OLATA funval
      :Else
            ⍝ Read PortB
          funret funval funerr←I2CBus.ReadBytes DeviceAddress OLATB 0
            ⍝ Boolean endcode read value and select pin with HSB correction
          funval←((8⍴2)⊤funval)[16-pin]
            ⍝ Build return value
          funval←OLATB funval
      :EndIf
        ⍝ Return result
      r←funret funval funerr
    ∇

    ⍝ Debug utility (shall be commented out when not in use)
    ∇ r←debug exp
      :Access Public
      r←⍎exp
    ∇

    ⍝ Destructor
    ∇ close;r
      :Implements Destructor
      _LOG'MCP23017 at Bus:Address=',(1 0⍕I2CBus.getBusID),':',⍕DeviceAddress,'will be closed.'
      r←I2CBus.CloseBus
      I2CBus←⍬
      r←0
    ∇

    ⍝ Test class methode 
    ∇ r←Test;dev
      :Access Public Shared
      dev←⍬
      dev←⎕NEW MCP23017 33
      {dev.Config ⍵ 0}¨(¯1+⍳16)
      {dev.Output ⍵ 0}¨(¯1+⍳16)
      dev.Config8 0
      dev.Config16 0
      dev.Write8 255
      dev.Write16 65535
      dev.Output 0 0
      dev.Output 1 0
      dev.Output 2 0
      dev.Output 3 0
      dev.Output 12 0
      dev.Output 13 0
      dev.Output 14 0
      dev.Output 15 0
      dev.Input 0
      dev.Input 7
      dev.Input 8
      dev.Input 15
     
      r←dev
    ∇

:EndClass


⍝class Adafruit_MCP230XX(object):
⍝        # set defaults
⍝        if num_gpios <= 8:
⍝            self.i2c.write8(MCP23017_IODIRA, 0xFF)  # all inputs on port A
⍝            self.direction = self.i2c.readU8(MCP23017_IODIRA)
⍝            self.i2c.write8(MCP23008_GPPUA, 0x00)
⍝        elif num_gpios > 8 and num_gpios <= 16:
⍝            self.i2c.write8(MCP23017_IODIRA, 0xFF)  # all inputs on port A
⍝            self.i2c.write8(MCP23017_IODIRB, 0xFF)  # all inputs on port B
⍝            self.direction = self.i2c.readU8(MCP23017_IODIRA)
⍝            self.direction |= self.i2c.readU8(MCP23017_IODIRB) << 8
⍝            self.i2c.write8(MCP23017_GPPUA, 0x00)
⍝            self.i2c.write8(MCP23017_GPPUB, 0x00)
⍝
⍝if __name__ == '__main__':
⍝    # ***************************************************
⍝    # Set num_gpios to 8 for MCP23008 or 16 for MCP23017!
⍝    # ***************************************************
⍝    mcp = Adafruit_MCP230XX(address = 0x20, num_gpios = 8) # MCP23008
⍝    # mcp = Adafruit_MCP230XX(address = 0x20, num_gpios = 16) # MCP23017
⍝
⍝    # Set pins 0, 1 and 2 to output (you can set pins 0..15 this way)
⍝    mcp.config(0, mcp.OUTPUT)
⍝    mcp.config(1, mcp.OUTPUT)
⍝    mcp.config(2, mcp.OUTPUT)
⍝
⍝    # Set pin 3 to input with the pullup resistor enabled
⍝    mcp.config(3, mcp.INPUT)
⍝    mcp.pullup(3, 1)
⍝
⍝    # Read input pin and display the results
⍝    print "Pin 3 = %d" % (mcp.input(3) >> 3)
⍝
⍝    # Python speed test on output 0 toggling at max speed
⍝    print "Starting blinky on pin 0 (CTRL+C to quit)"
⍝    while (True):
⍝      mcp.output(0, 1)  # Pin 0 High
⍝      time.sleep(1);
⍝      mcp.output(0, 0)  # Pin 0 Low
⍝      time.sleep(1);


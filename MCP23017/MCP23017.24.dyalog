:Class MCP23017
⍝∇:require =/../I2C/I2C.dyalog
    ⎕IO←⎕ML←1

    ⍝ Member objects
    ⍝ IC2 bus device is attached to
    :Field I2CBus

    ⍝ Local variables and constants
    ⍝ Device address
    DeviceAddress ← 32   ⍝ Default 0x20 (A0/A1/A2 set to low)
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

    ⍝ Tools
    _bool8  ←{(8⍴2)⊤⍵}   ⍝ Converts a decimal to a binary array of 8 bit
    _bool16 ←{(16⍴2)⊤⍵}  ⍝ Converts a decimal to a binary array of 16 bit
    _decimal←{2⊥⍵}       ⍝ Converts a arbitray binary to a decimal

    ⍝ Constructor methods
    ⍝ Device is initialized with a default I2C bus instance at address 32 (0x20)
    ∇ make0;r
      :Implements Constructor                                                                                                                                    
      :Access Public                                                                                                                                             
      I2CBus←⎕NEW ##.I2C
      r←initializeI2CBus
    ∇
    ⍝ Device is initialized with a default I2C bus at the given address
    ∇ make1 address;r
      :Implements Constructor
      :Access Public
      I2CBus←⎕NEW ##.I2C
      DeviceAddress←address
      r←initializeI2CBus
    ∇
    ⍝ Device is initialized with a given I2C bus an address
    ∇ make2(i2cbus address);r
      :Implements Constructor
      :Access Public
      I2CBus←i2cbus
      DeviceAddress←address
      r←initializeI2CBus
    ∇
    ⍝ Open I2C bus of this device
    ∇ r←initializeI2CBus
      r←I2CBus.OpenBus
      ⎕←'MCP23017 at Bus:Address=',(1 0⍕I2CBus.getBusID),':',⍕DeviceAddress,'is now alive.'
    ∇

    ⍝ Utility functions

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

    ⍝ Configure a pin as Input/Output (single pin operation)
    ⍝ pin         : index of pin/bit to change (First bit (2*0) is indicated by pin←0)
    ⍝ mode        : ←0 Configure pin as output, ←1 ..as input
    ⍝ returnvalue : funret IODIR-Register IODIR-Value I2CErrCode
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

    ⍝ Output Value to a GPIO Pin (single pin operation)
    ⍝ pin         : index of pin/bit to change (First bit (2*0) is indicated by pin←0)
    ⍝ value       : ←0 Set Pin to Low, ←1 ..to High
    ⍝ returnvalue : funret GPIO-Register GPIO-Value I2CErrCode
    ∇ r←Output(pin value)
      :Access Public
        ⍝ If pin is > 7 the PortB needs to be addressed
      :If pin<8
            ⍝ Configure addressed pin PortA
          r←readandchangepin GPIOA pin value
      :Else
            ⍝ Configure addressed pin of PortB
          r←readandchangepin GPIOB(pin-8)value
      :EndIf
    ∇

    ⍝ Read Operations from GPIO ports
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
    ⍝ Read 16 bit from latch register OLATA/OLATN
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

    ⍝ Debug utility (shall be commented out when not in use)
    ∇ r←debug exp
      :Access Public
      r←⍎exp
    ∇

    ⍝ Destructor
    ∇ close;r
      :Implements Destructor
      ⎕←'MCP23017 at Bus:Address=',(1 0⍕I2CBus.getBusID),':',⍕DeviceAddress,'will be closed.'
      r←I2CBus.CloseBus
      I2CBus←⍬
      r←0
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
⍝    def pullup(self, pin, value):
⍝        if self.num_gpios <= 8:
⍝            return self._readandchangepin(MCP23008_GPPUA, pin, value)
⍝        if self.num_gpios <= 16:
⍝            lvalue = self._readandchangepin(MCP23017_GPPUA, pin, value)
⍝            if (pin < 8):
⍝                return
⍝            else:
⍝                return self._readandchangepin(MCP23017_GPPUB, pin-8, value) << 8
⍝
⍝        self.outputvalue = self._readandchangepin(MCP23017_IODIRA, pin, value, self.outputvalue)
⍝        return self.outputvalue
⍝
⍝    def input(self, pin):
⍝        assert pin >= 0 and pin < self.num_gpios, "Pin number %s is invalid, only 0-%s are valid" % (pin, self.num_gpios)
⍝        assert self.direction & (1 << pin) != 0, "Pin %s not set to input" % pin
⍝        if self.num_gpios <= 8:
⍝            value = self.i2c.readU8(MCP23008_GPIOA)
⍝        elif self.num_gpios > 8 and self.num_gpios <= 16:
⍝            value = self.i2c.readU8(MCP23017_GPIOA)
⍝            value |= self.i2c.readU8(MCP23017_GPIOB) << 8
⍝        return value & (1 << pin)
⍝
⍝
⍝    def readU16(self):
⍝        assert self.num_gpios >= 16, "16bits required"
⍝        lo = self.i2c.readU8(MCP23017_OLATA)
⍝        hi = self.i2c.readU8(MCP23017_OLATB)
⍝        return((hi << 8) | lo)
⍝
⍝    def readS16(self):
⍝        assert self.num_gpios >= 16, "16bits required"
⍝        lo = self.i2c.readU8(MCP23017_OLATA)
⍝        hi = self.i2c.readU8(MCP23017_OLATB)
⍝        if (hi > 127): hi -= 256
⍝        return((hi << 8) | lo)
⍝
⍝    def write8(self, value):
⍝        self.i2c.write8(MCP23008_OLATA, value)
⍝
⍝    def write16(self, value):
⍝        assert self.num_gpios >= 16, "16bits required"
⍝        self.i2c.write8(MCP23017_OLATA, value & 0xFF)
⍝        self.i2c.write8(MCP23017_OLATB, (value >> 8) & 0xFF)
⍝
⍝# RPi.GPIO compatible interface for MCP23017 and MCP23008
⍝
⍝class MCP230XX_GPIO(object):
⍝    OUT = 0
⍝    IN = 1
⍝    BCM = 0
⍝    BOARD = 0
⍝    def __init__(self, busnum, address, num_gpios):
⍝        self.chip = Adafruit_MCP230XX(address, num_gpios, busnum)
⍝    def setmode(self, mode):
⍝        # do nothing
⍝        pass
⍝    def setup(self, pin, mode):
⍝        self.chip.config(pin, mode)
⍝    def input(self, pin):
⍝        return self.chip.input(pin)
⍝    def output(self, pin, value):
⍝        self.chip.output(pin, value)
⍝    def pullup(self, pin, value):
⍝        self.chip.pullup(pin, value)
⍝
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

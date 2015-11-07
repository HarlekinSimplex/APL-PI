:Class MCP23017
⍝∇:require =/../I2C/I2C.dyalog
    ⎕IO←⎕ML←1

    ⍝ Member obje cts
    ⍝ IC2 bus device is attached to
    :Field I2CBus

    ⍝ Local variables and constants
    ⍝ Device address
    DeviceAddress ← 32   ⍝ 0x20 A0/A1/A2 set to low
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
    _bool8 ←{(8⍴2)⊤⍵}   ⍝ Converts a decimal to a binary array of 8 bit
    _bool16←{(16⍴2)⊤⍵}  ⍝ Converts a decimal to a binary array of 16 bit

    ⍝ Constructor methods
    ∇ make0;r
      :Implements Constructor                                                                                                                                    
      :Access Public                                                                                                                                             
      I2CBus←⎕NEW ##.I2C
      r←initializeI2CBus
    ∇
    ∇ make1 address;r
      :Implements Constructor
      :Access Public
      I2CBus←⎕NEW ##.I2C
      DeviceAddress←address
      r←initializeI2CBus
    ∇
    ∇ make2(i2cbus address);r
      :Implements Constructor
      :Access Public
      I2CBus←i2cbus
      DeviceAddress←address
      r←initializeI2CBus
    ∇
    ∇ r←initializeI2CBus
      r←I2CBus.OpenBus
      ⎕←'MCP23017 at Bus:Address=',(1 0⍕I2CBus.getBusID),':',⍕DeviceAddress,'is now alive.'
    ∇

    ⍝ Utilities functions

    ⍝ Clear or set given bit in bitmap according value
    ⍝ value=0  Clear bit
    ⍝ value=1  Set bit
    ⍝ First bit (2*0) is indicated by bit←0
    ⍝ bitmap is a vector of booleans e.g. bitmap←0 0 0 1
    ∇ r←_changebit(bitmap bit value)
      :If value=0
          r←bitmap∧(~bit⌽((⍴bitmap)⍴2)⊤1) ⍝ Clear given bit
      :Else
          r←bitmap∨(bit⌽((⍴bitmap)⍴2)⊤1)  ⍝ Set given bit
      :EndIf
    ∇

⍝        def _readandchangepin(self, port, pin, value, currvalue = None):
⍝        assert pin >= 0 and pin < self.num_gpios, "Pin number %s is invalid, only 0-%s are valid" % (pin, self.num_gpios)
⍝        #assert self.direction & (1 << pin) == 0, "Pin %s not set to output" % pin
⍝        if not currvalue:
⍝             currvalue = self.i2c.readU8(port)
⍝        newvalue = self._changebit(currvalue, pin, value)
⍝        self.i2c.write8(port, newvalue)
⍝        return newvalue
⍝
    ∇ r←_readandchangepin(port pin value currvalue);newvalue;funret;funerr
      :If currvalue=⍬
          funret funerr←I2CBus.WriteBytes DeviceAddress port
          funret currvalue funerr←I2CBus.ReadBytes DeviceAddress 0
      :EndIf
      :If funret≠0
          r←funret currvalue funerr
      :ElseIf
          newvalue←2⊥(_changebit(_bool8 currvalue)pin value)
          funret funerr←I2CBus.WriteBytes(DeviceAddress newvalue)
          r←funret newvalue funerr
      :EndIf
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
⍝    OUTPUT = 0
⍝    INPUT = 1
⍝
⍝    def __init__(self, address, num_gpios, busnum=-1):
⍝        assert num_gpios >= 0 and num_gpios <= 16, "Number of GPIOs must be between 0 and 16"
⍝        self.i2c = Adafruit_I2C(address=address, busnum=busnum)
⍝        self.address = address
⍝        self.num_gpios = num_gpios
⍝
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
⍝    # Set pin to either input or output mode
⍝    def config(self, pin, mode):
⍝        if self.num_gpios <= 8:
⍝            self.direction = self._readandchangepin(MCP23017_IODIRA, pin, mode)
⍝        if self.num_gpios <= 16:
⍝            if (pin < 8):
⍝                self.direction = self._readandchangepin(MCP23017_IODIRA, pin, mode)
⍝            else:
⍝                self.direction |= self._readandchangepin(MCP23017_IODIRB, pin-8, mode) << 8
⍝
⍝        return self.direction
⍝
⍝    def output(self, pin, value):
⍝        # assert self.direction & (1 << pin) == 0, "Pin %s not set to output" % pin
⍝        if self.num_gpios <= 8:
⍝            self.outputvalue = self._readandchangepin(MCP23008_GPIOA, pin, value, self.i2c.readU8(MCP23008_OLATA))
⍝        if self.num_gpios <= 16:
⍝            if (pin < 8):
⍝                self.outputvalue = self._readandchangepin(MCP23017_GPIOA, pin, value, self.i2c.readU8(MCP23017_OLATA))
⍝            else:
⍝                self.outputvalue = self._readandchangepin(MCP23017_GPIOB, pin-8, value, self.i2c.readU8(MCP23017_OLATB)) << 8
⍝
⍝        return self.outputvalue
⍝
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
⍝    def readU8(self):
⍝        result = self.i2c.readU8(MCP23008_OLATA)
⍝        return(result)
⍝
⍝    def readS8(self):
⍝        result = self.i2c.readU8(MCP23008_OLATA)
⍝        if (result > 127): result -= 256
⍝        return result
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

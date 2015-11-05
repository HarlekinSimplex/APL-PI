:Class MCP23017
⍝∇:require /home/pi/github/APL-PI/I2C/I2C.dyalog

    ⍝ IC2 bus device is attached to
    :Field I2CBus

    ⍝ Device address
    :Field DeviceAdrress ← 32      ⍝ 0x20 A0/A1/A2 set to low

    ⍝ MCP23017 Register addresses
    :Field MCP23017_IODIRA ← 0     ⍝ 0x00
    :Field MCP23017_IODIRB ← 1     ⍝ 0x01
    :Field MCP23017_GPIOA  ← 18    ⍝ 0x12
    :Field MCP23017_GPIOB  ← 19    ⍝ 0x13
    :Field MCP23017_GPPUA  ← 12    ⍝ 0x0C
    :Field MCP23017_GPPUB  ← 13    ⍝ 0x0D
    :Field MCP23017_OLATA  ← 20    ⍝ 0x14
    :Field MCP23017_OLATB  ← 21    ⍝ 0x15

    ⍝ Constructor methods
    ∇ make address;r
      :Implements Constructor
      :Access Public
      I2CBus←⎕NEW ##.I2C
      r←I2CBus.OpenBus 1
      DeviceAddress←address
      ⎕←'MCP23017 at bus:address ',⍕I2CBus.getBusID,':',⍕DeviceAddress,'is now alive.'
    ∇
⍝    ∇ make(i2cbus address);r
⍝      :Implements Constructor
⍝      :Access Public
⍝      I2CBus←i2cbus
⍝      r←I2CBus.OpenBus 1
⍝      DeviceAddress←address
⍝      ⎕←'MCP23017 at bus:address ',⍕I2CBus.getBusID,':',⍕DeviceAddress,'is now alive.'
⍝    ∇

    ⍝ Destructor
    ∇ close;r
      :Implements Destructor
      r←I2CBus.CloseBus
      I2CBus←⍬
      ⎕←'MCP23017 at address ',⍕DeviceAddress,'was closed.'
      r←0
    ∇

:EndClass

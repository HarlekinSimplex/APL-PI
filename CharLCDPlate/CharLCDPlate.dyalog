:Class CharLCDPlate
⍝ Dyalog APL class for Adafruit RGB-backlit LCD plate for Raspberry Pi
⍝
⍝ Dyalog APL port based on Python library for Adafruit RGB-backlit LCD plate for Raspberry Pi.
⍝ Written by Adafruit Industries.  MIT license.

⍝∇:require =/../MCP23017/MCP23017.dyalog
    ⎕IO←⎕ML←1

    ⍝ ----------------------------------------------------------------------
    ⍝ Tools
    ⍝
    ⍝ Hex/Boolean Tools
    x2d ←{⍺⊥('0123456789ABCDEF'⍳⍵)-1}             ⍝ Converts a ⍺ based string to a decimal
    h2d ←{16x2d⍵}                                 ⍝ Converts a hex string to a decimal
    b2d ←{2x2d⍵}                                  ⍝ Converts a boolean string to a decimal
    d2x ←{'0123456789ABCDEF'[1+(((⌊⍺⍟⍵)+1)⍴⍺)⊤⍵]} ⍝ Converts a decimal to a ⍺ based string
    d2h ←{16d2x⍵}                                 ⍝ Converts a decimal to a hex string
    d2b ←{2d2x⍵}                                  ⍝ Converts a decimal to a boolean string
    d2xA←{(((⌊⍺⍟⍵)+1)⍴⍺)⊤⍵}                       ⍝ Converts a decimal to a ⍺ based array
    d2bA←{2d2xA⍵}                                 ⍝ Converts a decimal to a boolean array

    ⍝ ----------------------------------------------------------------------
    ⍝ Constants
    ⍝
    ⍝ Port expander registers
    MCP23017_IOCON_BANK0    ← 10  ⍝ 0x0A IOCON when Bank 0 active
    MCP23017_IOCON_BANK1    ← 21  ⍝ 0x15 IOCON when Bank 1 active

    ⍝ These are register addresses when in Bank 1 only:
    MCP23017_GPIOA          ← 9   ⍝ 0x09
    MCP23017_IODIRB         ← 16  ⍝ 0x10
    MCP23017_GPIOB          ← 25  ⍝ 0x19

    ⍝ Port expander button input pin definitions
    SELECT                  ← 0
    RIGHT                   ← 1
    DOWN                    ← 2
    UP                      ← 3
    LEFT                    ← 4

    ⍝ LED colors
    OFF                     ← 0   ⍝ 0x00
    RED                     ← 1   ⍝ 0x01
    GREEN                   ← 2   ⍝ 0x02
    BLUE                    ← 4   ⍝ 0x04
    YELLOW                  ← RED + GREEN
    TEAL                    ← GREEN + BLUE
    VIOLET                  ← RED + BLUE
    WHITE                   ← RED + GREEN + BLUE
    ON                      ← RED + GREEN + BLUE

    ⍝ LCD Commands
    LCD_CLEARDISPLAY        ← 1   ⍝ 0x01
    LCD_RETURNHOME          ← 2   ⍝ 0x02
    LCD_ENTRYMODESET        ← 4   ⍝ 0x04
    LCD_DISPLAYCONTROL      ← 8   ⍝ 0x08
    LCD_CURSORSHIFT         ← 16  ⍝ 0x10
    LCD_FUNCTIONSET         ← 32  ⍝ 0x20
    LCD_SETCGRAMADDR        ← 64  ⍝ 0x40
    LCD_SETDDRAMADDR        ← 128 ⍝ 0x80

    ⍝ Flags for display on/off control
    LCD_DISPLAYON           ← 4   ⍝ 0x04
    LCD_DISPLAYOFF          ← 0   ⍝ 0x00
    LCD_CURSORON            ← 2   ⍝ 0x02
    LCD_CURSOROFF           ← 0   ⍝ 0x00
    LCD_BLINKON             ← 1   ⍝ 0x01
    LCD_BLINKOFF            ← 0   ⍝ 0x00

    ⍝ Flags for display entry mode
    LCD_ENTRYRIGHT          ← 0   ⍝ 0x00
    LCD_ENTRYLEFT           ← 2   ⍝ 0x02
    LCD_ENTRYSHIFTINCREMENT ← 1   ⍝ 0x01
    LCD_ENTRYSHIFTDECREMENT ← 0   ⍝ 0x00

    ⍝ Flags for display/cursor shift
    LCD_DISPLAYMOVE         ← 8   ⍝ 0x08
    LCD_CURSORMOVE          ← 0   ⍝ 0x00
    LCD_MOVERIGHT           ← 4   ⍝ 0x04
    LCD_MOVELEFT            ← 0   ⍝ 0x00

    ⍝ Construct some display commands
    Displayshift   ← (8⍴2⊤LCD_CURSORMOVE)∨(8⍴2⊤LCD_MOVERIGHT)
    Displaymode    ← (8⍴2⊤LCD_ENTRYLEFT)∨(8⍴2⊤LCD_ENTRYSHIFTDECREMENT)
    Displaycontrol ← (8⍴2⊤LCD_DISPLAYON)∨(8⍴2⊤LCD_CURSOROFF)∨(8⍴2⊤LCD_BLINKOFF)

    ⍝ Truncation constants for message function truncate parameter.
    NO_TRUNCATE             ← 0
    TRUNCATE                ← 1
    TRUNCATE_ELLIPSIS       ← 2

    ⍝ Line addresses for up to 4 line displays.  Maps line number to DDRAM address for line.
    LINE_ADDRESSES          ← (h2d'C0')(h2d'94')(h2d'D4')

    ⍝ ----------------------------------------------------------------------
    ⍝ Fields
    ⍝
    :Field Public MCP
    :Field Public PortA
    :Field Public PortB
    :Field Public DDRB

    ⍝ ----------------------------------------------------------------------
    ⍝ Constructor
    ⍝
    ∇ make0
      :Implements Constructor
      :Access Public
      make1(h2d'20')            ⍝ Default address 0x20
    ∇
    ∇ make1 addr
      :Implements Constructor
      :Access Public
      make2 addr ON              ⍝ Default backlight ON (White)
    ∇
    ∇ make2(addr backlight)
      :Implements Constructor
      :Access Public
      make3 addr backlight 0     ⍝ Default debug off
    ∇
    ∇ make3(addr backlight debug);c
      :Implements Constructor
      :Access Public
     
        ⍝ Instantiate Port Expander
      MCP←⎕NEW #.MCP23017 32     ⍝ 0x20
     
        ⍝ I2C is relatively slow. MCP output port states are cached
        ⍝ so we don't need to constantly poll-and-change bit states.
      PortA PortB DDRB←(8⍴0)(8⍴0)(0 0 0 0 0 0 1 0)
     
        ⍝ Set initial backlight color as 8 bit boolean array
        ⍝ to the inverse of the default ON
      c←~8⍴2⊤backlight
        ⍝ Post backlight value to output register cache
        ⍝ Color Bit 0 and 1 are connected to PortA Bit 6 and 7
        ⍝ Color Bit 2 is connected to PortB Bit 0
      PortA←(PortA∧(0 0 1 1 1 1 1 1))∨(¯2⌽c∧(0 0 0 0 0 0 1 1))
      PortB←(PortB∧(1 1 1 1 1 1 1 0))∨(¯2⌽c∧(0 0 0 0 0 1 0 0))
     
        ⍝ Set MCP23017 IOCON register to Bank 0 with sequential operation.
        ⍝ If chip is already set for Bank 0, this will just write to OLATB
        ⍝ which won't seriously bother anything on the plate right now
        ⍝ (blue backlight LED will come on, but that's done in the next
        ⍝ step anyway).
      MCP.WriteBytes MCP23017_IOCON_BANK1(0)
     
        ⍝ Brute force reload ALL registers to known state.
        ⍝ This also sets up all the input pins, pull-ups, etc. for the Pi Plate.
        ⍝ Assemble data block to write to MCP
      initdata←2⊥(0 0 1 1 1 1 1 1)  ⍝ IODIRA    R+G LEDs=outputs, buttons=inputs
      initdata,←2⊥DDRB               ⍝ LCD       D7=input, Blue LED=output
      initdata,←2⊥(0 0 1 1 1 1 1 1)  ⍝ IPOLA     Invert polarity on button inputs
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ IPOLB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ GPINTENA  Disable interrupt-on-change
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ GPINTENB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ DEFVALA
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ DEFVALB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTCONA
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTCONB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ IOCON
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ IOCON
      initdata,←2⊥(0 0 1 1 1 1 1 1)  ⍝ GPPUA     Enable pull-ups on buttons
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ GPPUB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTFA
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTFB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTCAPA
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTCAPB
      initdata,←2⊥PortA              ⍝ GPIOA
      initdata,←2⊥PortB              ⍝ GPIOB
      initdata,←2⊥PortA              ⍝ OLATA
      initdata,←2⊥PortB              ⍝ OLATB
        ⍝ Write init data to MCP
        ⍝ Blockwrite of configuration data to address 0 (IODIRA) onwards
      MCP.WriteBytes 0(initdata)
     
        ⍝ Switch to Bank 1 and disable sequential operation.
        ⍝ From this point forward, the register addresses do NOT match
        ⍝ the list immediately above.  Instead, use the constants defined
        ⍝ at the start of the class.  Also, the address register will no
        ⍝ longer increment automatically after this -- multi-byte
        ⍝ # operations must be broken down into single-byte calls.
      MCP.WriteBytes MCP23017_IOCON_BANK0(2⊥(1 0 1 0 0 0 0 0))
     
        ⍝ Initialize display
      WriteData 16⊥3 3  ⍝ 0x33 - Init
      WriteData 16⊥3 2  ⍝ 0x32 - Init
      WriteData 16⊥2 8  ⍝ 0x28 - 2 line 5x8 matrix
      WriteData 2⊥(8⍴2⊤LCD_CLEARDISPLAY)
      WriteData 2⊥(8⍴2⊤LCD_CURSORSHIFT)∨Displayshift
      WriteData 2⊥(8⍴2⊤LCD_ENTRYMODESET)∨Displaymode
      WriteData 2⊥(8⍴2⊤LCD_DISPLAYCONTROL)∨Displaycontrol
      WriteData 2⊥(8⍴2⊤LCD_RETURNHOME)
     
      ⎕←'Adafruit Char LCD Plate at address ',⍕addr,'with Debug',(('OFF' 'ON')[debug+1]),'and backlight b',(d2b backlight),' is alive.'
    ∇

    ⍝ ----------------------------------------------------------------------
    ⍝ Write operations
    ⍝

    ⍝ The LCD data pins (D4-D7) connect to MCP pins 12-9 (PORTB4-1), in
    ⍝ that order. Because this sequence is 'reversed,' a direct shift
    ⍝ won't work. This table remaps 4-bit data values to MCP PORTB
    ⍝ outputs, incorporating both the reverse and shift.
    ⍝ Usage: flip[1+2⊥ _bAarray2flip_ ]
    flip ←(0 0 0 0 0 0 0 0)(0 0 0 1 0 0 0 0)(0 0 0 0 1 0 0 0)(0 0 0 1 1 0 0 0)
    flip,←(0 0 0 0 0 1 0 0)(0 0 0 1 0 1 0 0)(0 0 0 0 1 1 0 0)(0 0 0 1 1 1 0 0)
    flip,←(0 0 0 0 0 0 1 0)(0 0 0 1 0 0 1 0)(0 0 0 0 1 0 1 0)(0 0 0 1 1 0 1 0)
    flip,←(0 0 0 0 0 1 1 0)(0 0 0 1 0 1 1 0)(0 0 0 0 1 1 1 0)(0 0 0 1 1 1 1 0) 

    ⍝ Low-level 4-bit interface for LCD output.  This doesn't actually
    ⍝ write data, just returns an array of boolean arrays of the PORTB state over time.
    ⍝ Can concatenate the output of multiple calls (up to 8) for more
    ⍝ efficient batch write.
    ∇ r←out4(bitmask value);lo;hi
      hi←bitmask∨⊃flip[1+2⊥(1 1 1 1 0 0 0 0)/value]
      lo←bitmask∨⊃flip[1+2⊥(0 0 0 0 1 1 1 1)/value]
      r←(hi∨(0 0 1 0 0 0 0 0))hi(lo∨(0 0 1 0 0 0 0 0))lo
    ∇

    ⍝ The speed of LCD accesses is inherently limited by I2C through the
    ⍝ port expander. A 'well behaved program' is expected to poll the
    ⍝ LCD to know that a prior instruction completed.  But the timing of
    ⍝ most instructions is a known uniform 37 mS. The enable strobe
    ⍝ can't even be twiddled that fast through I2C, so it's a safe bet
    ⍝ with these instructions to not waste time polling (which requires
    ⍝ several I2C transfers for reconfiguring the port direction).
    ⍝ The D7 pin is set as input when a potentially time-consuming
    ⍝ instruction has been issued (e.g. screen clear), as well as on
    ⍝ startup, and polling will then occur before more commands or data
    ⍝ are issued.
    pollables ← LCD_CLEARDISPLAY LCD_RETURNHOME

    ⍝ Write byte, list or string value to LCD
    ∇ r←WriteData value
        ⍝ Call Write with CharMode←False
      r←Write value 0
    ∇
    ∇ r←WriteChar value
        ⍝ Call Write with CharMode←True
      r←Write value 1
    ∇
    ∇ r←Write(value charmode);lo;hi;funret;funval;funerr;bits;data
        ⍝ Busy Flag Poll
        ⍝ If pin D7 is in input state, poll LCD busy flag until clear.
      :If (8⍴0)≢(DDRB∧(0 0 0 0 0 0 1 0))
          ⎕←'Initiate Busy Flag Poll'
            ⍝ Preserve Blue LED pin
          lo←(PortB∧(0 0 0 0 0 0 0 1))∨(0 1 0 0 0 0 0 0)
            ⍝ E=1 (strobe)
          hi←lo∨(0 0 1 0 0 0 0 0)
            ⍝ Write
          MCP.WriteBytes MCP23017_GPIOB(2⊥lo)
     
            ⍝ Poll LCD busy flag
          :Repeat
                ⍝ Strobe high (enable)
              MCP.SequentialWriteBytes(2⊥hi)
                ⍝ First nybble contains busy state
              funret bits funerr←MCP.SequentialReadBytes 0
                ⍝ Strobe low, high, low.  Second nybble (A3) is ignored.
              MCP.WriteBytes MCP23017_GPIOB(2⊥¨lo hi lo)
              PortB←lo
            ⍝ D7=0,not busy
          :Until (8⍴0)≡(bits∧(0 0 0 0 0 0 1 0))
          ⎕←'Poll completed'
     
            ⍝  Polling complete, change D7 pin to output
          DDRB←DDRB∧(1 1 1 1 1 1 0 1)
          MCP.WriteBytes MCP23017_IODIRB(2⊥DDRB)
      :Else
          ⎕←'No Poll required'
      :EndIf
     
        ⍝ Mask out PORTB LCD control bits
      bitmask←PortB∧(0 0 0 0 0 0 0 1)
      :If charmode
            ⍝ Set data bit if not a command
          bitmask←bitmask∨(1 0 0 0 0 0 0 0)
      :EndIf
     
        ⍝ Convert values in value into boolean arrays of 8 bit
        ⍝ Resulting array will be processed by out4 (flip and hi/lo strobe)
        ⍝ Finally remove enclosure and catenate the boolean arrays
        ⍝ 'data' now holds an array of bytes to be sent in chunks of 32 bytes
        ⍝ to MCP device
      data←,↑{out4 bitmask ⍵}¨{(8⍴2)⊤⍵}¨value
     
        ⍝ Set PortB to last byte that will be send
      PortB←⊃¯1↑data
     
        ⍝ Decode data to decimal
      data←2⊥¨data
     
        ⍝ Write data split into 32 bytes chunks
        ⍝ Loop runs as long as there are data bytes to send
      :While (⍴data)≠0
            ⍝ Check if we still have 32 or more bytes left
          :If (⍴data)≥32
                ⍝ Send 32 bytes and drop them from queue afterwards
              ⎕←'Send 32 bytes'
              MCP.WriteBytes MCP23017_GPIOB(32↑data)
              data←32↓data
          :Else
                ⍝ Last chunk is less then 32 bytes
                ⍝ Send and drop them after send
              ⎕←'Send ',(⍕⍴data),' bytes'
              MCP.WriteBytes MCP23017_GPIOB data
              data←⍬
          :EndIf
      :EndWhile
     
        ⍝ If a poll-worthy instruction was issued, reconfigure D7
        ⍝ pin as input to indicate need for polling on next call.
      :If (~charmode)∧(1↑value)∊pollables
          ⎕←'Set Poll indicator'
          DDRB←DDRB∨(0 0 0 0 0 0 1 0)
          MCP.WriteBytes MCP23017_IODIRB(2⊥DDRB)
      :EndIf
     
      r←0
    ∇

    ⍝ ----------------------------------------------------------------------
    ⍝ Destructor
    ⍝
    ∇ close;r
      :Implements Destructor
      ⎕←'Adafruit Char LCD Plate at address ',⍕MCP.DeviceAddress,'will be closed.'
     
        ⍝ Puts the MCP23017 back in Bank 0 + sequential write mode
      MCP.WriteBytes MCP23017_IOCON_BANK1(0)
     
        ⍝ Turn off LEDs on the way out
      PortA←1 1 0 0 0 0 0 0
      PortB←0 0 0 0 0 0 0 1
⍝        sleep(0.0015)
     
        ⍝ Brute force reload ALL registers to known state.
        ⍝ This also sets up all the input pins, pull-ups, etc. for the Pi Plate.
        ⍝ Assemble data block to write to MCP
      initdata←2⊥(0 0 1 1 1 1 1 1)   ⍝ IODIRA    R+G LEDs=outputs, buttons=inputs
      initdata,←2⊥DDRB               ⍝ LCD       D7=input, Blue LED=output
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ IPOLA
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ IPOLB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ GPINTENA  Disable interrupt-on-change
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ GPINTENB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ DEFVALA
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ DEFVALB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTCONA
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTCONB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ IOCON
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ IOCON
      initdata,←2⊥(0 0 1 1 1 1 1 1)  ⍝ GPPUA     Enable pull-ups on buttons
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ GPPUB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTFA
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTFB
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTCAPA
      initdata,←2⊥(0 0 0 0 0 0 0 0)  ⍝ INTCAPB
      initdata,←2⊥PortA              ⍝ GPIOA
      initdata,←2⊥PortB              ⍝ GPIOB
      initdata,←2⊥PortA              ⍝ OLATA
      initdata,←2⊥PortB              ⍝ OLATB
        ⍝ Write init data to MCP
        ⍝ Blockwrite of configuration data to address 0 (IODIRA) onwards
      MCP.WriteBytes 0(initdata)
     
        ⍝ Deconstruct MCP23017 Insatance
      MCP←⍬
      r←0
    ∇

    ⍝ ----------------------------------------------------------------------
    ⍝ Debug utility (shall be commented out when not in use)
    ⍝
    ∇ r←debug exp
      :Access Public
      r←⍎exp
    ∇

⍝
⍝    # ----------------------------------------------------------------------
⍝    # Utility methods
⍝
⍝    def begin(self, cols, lines):
⍝        self.currline = 0
⍝        self.numlines = lines
⍝        self.numcols = cols
⍝        self.clear()
⍝
⍝    def clear(self):
⍝        self.write(self.LCD_CLEARDISPLAY)
⍝
⍝
⍝    def home(self):
⍝        self.write(self.LCD_RETURNHOME)
⍝
⍝
⍝    row_offsets = ( 0x00, 0x40, 0x14, 0x54 )
⍝    def setCursor(self, col, row):
⍝        if row > self.numlines: row = self.numlines - 1
⍝        elif row < 0:           row = 0
⍝        self.write(self.LCD_SETDDRAMADDR | (col + self.row_offsets[row]))
⍝
⍝
    ⍝ Turn the display on (quickly)
    ∇ r←DisplayOn
      :Access Public
      Displaycontrol∨←(8⍴2)⊤LCD_DISPLAYON
      WriteData 2⊥Displaycontrol∨(8⍴2)⊤LCD_DISPLAYCONTROL
    ∇

    ⍝ Turn the display off (quickly)
    ∇ r←DisplayOff
      :Access Public
      Displaycontrol∧←~(8⍴2)⊤LCD_DISPLAYON
      WriteData 2⊥Displaycontrol∨(8⍴2)⊤LCD_DISPLAYCONTROL
    ∇

⍝    def cursor(self):
⍝        """ Underline cursor on """
⍝        self.displaycontrol |= self.LCD_CURSORON
⍝        self.write(self.LCD_DISPLAYCONTROL | self.displaycontrol)
    ∇ r←CursorOn
      :Access Public
      Displaycontrol∨←(8⍴2)⊤LCD_CURSORON
      WriteData 2⊥Displaycontrol∨(8⍴2)⊤LCD_DISPLAYCONTROL
    ∇
⍝
⍝    def noCursor(self):
⍝        """ Underline cursor off """
⍝        self.displaycontrol &= ~self.LCD_CURSORON
⍝        self.write(self.LCD_DISPLAYCONTROL | self.displaycontrol)
    ∇ r←CursorOff
      :Access Public
      Displaycontrol∧←~(8⍴2)⊤LCD_CURSORON
      WriteData 2⊥Displaycontrol∨(8⍴2)⊤LCD_DISPLAYCONTROL
    ∇
⍝
⍝
⍝    def ToggleCursor(self):
⍝        """ Toggles the underline cursor On/Off """
⍝        self.displaycontrol ^= self.LCD_CURSORON
⍝        self.write(self.LCD_DISPLAYCONTROL | self.displaycontrol)
⍝
⍝
⍝    def blink(self):
⍝        """ Turn on the blinking cursor """
⍝        self.displaycontrol |= self.LCD_BLINKON
⍝        self.write(self.LCD_DISPLAYCONTROL | self.displaycontrol)
⍝
⍝
⍝    def noBlink(self):
⍝        """ Turn off the blinking cursor """
⍝        self.displaycontrol &= ~self.LCD_BLINKON
⍝        self.write(self.LCD_DISPLAYCONTROL | self.displaycontrol)
⍝
⍝
⍝    def ToggleBlink(self):
⍝        """ Toggles the blinking cursor """
⍝        self.displaycontrol ^= self.LCD_BLINKON
⍝        self.write(self.LCD_DISPLAYCONTROL | self.displaycontrol)
⍝
⍝
⍝    def scrollDisplayLeft(self):
⍝        """ These commands scroll the display without changing the RAM """
⍝        self.displayshift = self.LCD_DISPLAYMOVE | self.LCD_MOVELEFT
⍝        self.write(self.LCD_CURSORSHIFT | self.displayshift)
⍝
⍝
⍝    def scrollDisplayRight(self):
⍝        """ These commands scroll the display without changing the RAM """
⍝        self.displayshift = self.LCD_DISPLAYMOVE | self.LCD_MOVERIGHT
⍝        self.write(self.LCD_CURSORSHIFT | self.displayshift)
⍝
⍝
⍝    def leftToRight(self):
⍝        """ This is for text that flows left to right """
⍝        self.displaymode |= self.LCD_ENTRYLEFT
⍝        self.write(self.LCD_ENTRYMODESET | self.displaymode)
⍝
⍝
⍝    def rightToLeft(self):
⍝        """ This is for text that flows right to left """
⍝        self.displaymode &= ~self.LCD_ENTRYLEFT
⍝        self.write(self.LCD_ENTRYMODESET | self.displaymode)
⍝
⍝
⍝    def autoscroll(self):
⍝        """ This will 'right justify' text from the cursor """
⍝        self.displaymode |= self.LCD_ENTRYSHIFTINCREMENT
⍝        self.write(self.LCD_ENTRYMODESET | self.displaymode)
⍝
⍝
⍝    def noAutoscroll(self):
⍝        """ This will 'left justify' text from the cursor """
⍝        self.displaymode &= ~self.LCD_ENTRYSHIFTINCREMENT
⍝        self.write(self.LCD_ENTRYMODESET | self.displaymode)
⍝
⍝
⍝    def createChar(self, location, bitmap):
⍝        self.write(self.LCD_SETCGRAMADDR | ((location & 7) << 3))
⍝        self.write(bitmap, True)
⍝        self.write(self.LCD_SETDDRAMADDR)
⍝
⍝
⍝    def message(self, text, truncate=NO_TRUNCATE):
⍝        """ Send string to LCD. Newline wraps to second line"""
⍝        lines = str(text).split('\n')    # Split at newline(s)
⍝        for i, line in enumerate(lines): # For each substring...
⍝            address = self.LINE_ADDRESSES.get(i, None)
⍝            if address is not None:      # If newline(s),
⍝                self.write(address)      #  set DDRAM address to line
⍝            # Handle appropriate truncation if requested.
⍝            linelen = len(line)
⍝            if truncate == self.TRUNCATE and linelen > self.numcols:
⍝                # Hard truncation of line.
⍝                self.write(line[0:self.numcols], True)
⍝            elif truncate == self.TRUNCATE_ELLIPSIS and linelen > self.numcols:
⍝                # Nicer truncation with ellipses.
⍝                self.write(line[0:self.numcols-3] + '...', True)
⍝            else:
⍝                self.write(line, True)
⍝
⍝
⍝
⍝    def backlight(self, color):
⍝        c          = ~color
⍝        self.porta = (self.porta & 0b00111111) | ((c & 0b011) << 6)
⍝        self.portb = (self.portb & 0b11111110) | ((c & 0b100) >> 2)
⍝        # Has to be done as two writes because sequential operation is off.
⍝        self.i2c.bus.write_byte_data(
⍝          self.i2c.address, self.MCP23017_GPIOA, self.porta)
⍝        self.i2c.bus.write_byte_data(
⍝          self.i2c.address, self.MCP23017_GPIOB, self.portb)
⍝
⍝
⍝    # Read state of single button
⍝    def buttonPressed(self, b):
⍝        return (self.i2c.readU8(self.MCP23017_GPIOA) >> b) & 1
⍝
⍝
⍝    # Read and return bitmask of combined button state
⍝    def buttons(self):
⍝        return self.i2c.readU8(self.MCP23017_GPIOA) & 0b11111
⍝
⍝
⍝    # ----------------------------------------------------------------------
⍝    # Test code
⍝
⍝if __name__ == '__main__':
⍝
⍝    lcd = Adafruit_CharLCDPlate()
⍝    lcd.begin(16, 2)
⍝    lcd.clear()
⍝    lcd.message("Adafruit RGB LCD\nPlate w/Keypad!")
⍝    sleep(1)
⍝
⍝    col = (('Red' , lcd.RED) , ('Yellow', lcd.YELLOW), ('Green' , lcd.GREEN),
⍝           ('Teal', lcd.TEAL), ('Blue'  , lcd.BLUE)  , ('Violet', lcd.VIOLET),
⍝           ('Off' , lcd.OFF) , ('On'    , lcd.ON))
⍝
⍝    print "Cycle thru backlight colors"
⍝    for c in col:
⍝       print c[0]
⍝       lcd.clear()
⍝       lcd.message(c[0])
⍝       lcd.backlight(c[1])
⍝       sleep(0.5)
⍝
⍝    btn = ((lcd.SELECT, 'Select', lcd.ON),
⍝           (lcd.LEFT  , 'Left'  , lcd.RED),
⍝           (lcd.UP    , 'Up'    , lcd.BLUE),
⍝           (lcd.DOWN  , 'Down'  , lcd.GREEN),
⍝           (lcd.RIGHT , 'Right' , lcd.VIOLET))
⍝    
⍝    print "Try buttons on plate"
⍝    lcd.clear()
⍝    lcd.message("Try buttons")
⍝    prev = -1
⍝    while True:
⍝        for b in btn:
⍝            if lcd.buttonPressed(b[0]):
⍝                if b is not prev:
⍝                    print b[1]
⍝                    lcd.clear()
⍝                    lcd.message(b[1])
⍝                    lcd.backlight(b[2])
⍝                    prev = b
⍝                break

:EndClass


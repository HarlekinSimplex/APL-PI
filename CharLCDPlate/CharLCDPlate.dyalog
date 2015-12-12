:Class CharLCDPlate
⍝ Dyalog APL class for Adafruit RGB-backlit LCD plate for Raspberry Pi
⍝
⍝ Dyalog APL port based on Python library for Adafruit RGB-backlit LCD plate for Raspberry Pi.
⍝ Written by Adafruit Industries.  MIT license.

⍝∇:require =/../MCP23017/MCP23017.dyalog
    ⎕IO←⎕ML←1

    ⍝ ----------------------------------------------------------------------
    ⍝ Debug
    ⍝

    ⍝ Console logging
    DEBUG ← 0            ⍝ Debug Flag Off:0 On:1
    _LOG←{DEBUG:1 ⎕←⍵}   ⍝ Console log output if DEBUG flag set TRUE

    ⍝ Debug expression utility to circumvent object encapsulation
    ⍝ (shall be commented out when not in use)
    ⍝
    ∇ r←Debug exp
      :Access Public
      r←⍎exp         ⍝ Evaluate given expression within actual object context
    ∇

    ⍝ ----------------------------------------------------------------------
    ⍝ Tools
    ⍝

    ⍝ Hex/Boolean Tools
    ⍝ used
    x2d   ←{⍺⊥(('0123456789',⎕A)⍳⍵)-1}              ⍝ Converts a ⍺ based string to a decimal
    h2d   ←{16x2d⍵}                                 ⍝ Converts a hex string to a decimal
    b2d   ←{2x2d⍵}                                  ⍝ Converts a boolean string to a decimal
    b8OR  ←{2⊥((8⍴2)⊤⍺)∨(8⍴2)⊤⍵}                    ⍝ Boolean OR  (8 bit)
    b8AND ←{2⊥((8⍴2)⊤⍺)∧(8⍴2)⊤⍵}                    ⍝ Boolean AND (8 bit)
    b8NOT ←{2⊥(~(8⍴2)⊤⍵)}                           ⍝ Boolean NOT (8 bit) 
    b8XOR ←{(⍵ b8AND b8NOT ⍺) b8OR ⍺ b8AND b8NOT ⍵} ⍝ Boolean XOR (8 bit)
    b8LSL ←{2⊥⍺⌽(8⍴2)⊤⍵}                            ⍝ Boolean Shift Left (8 bit)
    b8LSR ←{2⊥(-⍺)⌽(8⍴2)⊤⍵}                         ⍝ Boolean Shif Right (8 bit)

    ⍝ not used yet
⍝    d2x  ←{('0123456789',⎕A)[1+(((⌊⍺⍟⍵)+1)⍴⍺)⊤⍵]}  ⍝ Converts a decimal to a ⍺ based string
⍝    d2h  ←{16d2x⍵}                                 ⍝ Converts a decimal to a hex string
⍝    d2b  ←{2d2x⍵}                                  ⍝ Converts a decimal to a boolean string
⍝    d2xA ←{(((⌊⍺⍟⍵)+1)⍴⍺)⊤⍵}                       ⍝ Converts a decimal to a ⍺ based array
⍝    d2bA ←{2d2xA⍵}                                 ⍝ Converts a decimal to a boolean array

    ⍝ Cut utiliy
    ⍝
    ⍝ f← ⍺ Cut ⍵
    ⍝ ⍺: Delimiter sequence  '::'
    ⍝ ⍵: String to cut       'aaa::bbb::ccc'
    ⍝ f: Array of strings    'aaa' 'bbb' 'ccc'
    Cut←{⎕ML←3 ⋄ (~⍵∊⍺)⊂⍵}

    ⍝ ----------------------------------------------------------------------
    ⍝ Member Constants
    ⍝

    ⍝ Port expander registers
    :Field Private Shared ReadOnly MCP23017_IOCON_BANK0    ← 10  ⍝ 0x0A IOCON when Bank 0 active
    :Field Private Shared ReadOnly MCP23017_IOCON_BANK1    ← 21  ⍝ 0x15 IOCON when Bank 1 active

    ⍝ These are register addresses when in Bank 1 only:
    :Field Private Shared ReadOnly MCP23017_GPIOA          ← 9   ⍝ 0x09
    :Field Private Shared ReadOnly MCP23017_IODIRB         ← 16  ⍝ 0x10
    :Field Private Shared ReadOnly MCP23017_GPIOB          ← 25  ⍝ 0x19

    ⍝ Port expander button input pin definitions
    :Field Private Shared ReadOnly SELECT                  ← 0
    :Field Private Shared ReadOnly RIGHT                   ← 1
    :Field Private Shared ReadOnly DOWN                    ← 2
    :Field Private Shared ReadOnly UP                      ← 3
    :Field Private Shared ReadOnly LEFT                    ← 4

    ⍝ LED colors
    :Field Private Shared ReadOnly OFF                     ← 0   ⍝ 0x00
    :Field Private Shared ReadOnly RED                     ← 1   ⍝ 0x01
    :Field Private Shared ReadOnly GREEN                   ← 2   ⍝ 0x02
    :Field Private Shared ReadOnly BLUE                    ← 4   ⍝ 0x04
    :Field Private Shared ReadOnly YELLOW                  ← RED + GREEN
    :Field Private Shared ReadOnly TEAL                    ← GREEN + BLUE
    :Field Private Shared ReadOnly VIOLET                  ← RED + BLUE
    :Field Private Shared ReadOnly WHITE                   ← RED + GREEN + BLUE
    :Field Private Shared ReadOnly ON                      ← RED + GREEN + BLUE

    ⍝ LCD Commands
    :Field Private Shared ReadOnly LCD_CLEARDISPLAY        ← 1   ⍝ 0x01
    :Field Private Shared ReadOnly LCD_RETURNHOME          ← 2   ⍝ 0x02
    :Field Private Shared ReadOnly LCD_ENTRYMODESET        ← 4   ⍝ 0x04
    :Field Private Shared ReadOnly LCD_DISPLAYCONTROL      ← 8   ⍝ 0x08
    :Field Private Shared ReadOnly LCD_CURSORSHIFT         ← 16  ⍝ 0x10
    :Field Private Shared ReadOnly LCD_FUNCTIONSET         ← 32  ⍝ 0x20
    :Field Private Shared ReadOnly LCD_SETCGRAMADDR        ← 64  ⍝ 0x40
    :Field Private Shared ReadOnly LCD_SETDDRAMADDR        ← 128 ⍝ 0x80

    ⍝ Flags for display on/off control
    :Field Private Shared ReadOnly LCD_DISPLAYON           ← 4   ⍝ 0x04
    :Field Private Shared ReadOnly LCD_DISPLAYOFF          ← 0   ⍝ 0x00
    :Field Private Shared ReadOnly LCD_CURSORON            ← 2   ⍝ 0x02
    :Field Private Shared ReadOnly LCD_CURSOROFF           ← 0   ⍝ 0x00
    :Field Private Shared ReadOnly LCD_BLINKON             ← 1   ⍝ 0x01
    :Field Private Shared ReadOnly LCD_BLINKOFF            ← 0   ⍝ 0x00

    ⍝ Flags for display entry mode
    :Field Private Shared ReadOnly LCD_ENTRYRIGHT          ← 0   ⍝ 0x00
    :Field Private Shared ReadOnly LCD_ENTRYLEFT           ← 2   ⍝ 0x02
    :Field Private Shared ReadOnly LCD_ENTRYSHIFTINCREMENT ← 1   ⍝ 0x01
    :Field Private Shared ReadOnly LCD_ENTRYSHIFTDECREMENT ← 0   ⍝ 0x00

    ⍝ Flags for display/cursor shift
    :Field Private Shared ReadOnly LCD_DISPLAYMOVE         ← 8   ⍝ 0x08
    :Field Private Shared ReadOnly LCD_CURSORMOVE          ← 0   ⍝ 0x00
    :Field Private Shared ReadOnly LCD_MOVERIGHT           ← 4   ⍝ 0x04
    :Field Private Shared ReadOnly LCD_MOVELEFT            ← 0   ⍝ 0x00

    ⍝ Truncation constants for message function truncate parameter
    :Field Private Shared ReadOnly NO_TRUNCATE             ← 0
    :Field Private Shared ReadOnly TRUNCATE                ← 1   ⍝ same as NO_TRUNCATE!!
    :Field Private Shared ReadOnly TRUNCATE_ELLIPSIS       ← 2

    ⍝ Line addresses for up to 4 line displays.  Maps line number to DDRAM address for line
    :Field Private Shared ReadOnly LINE_ADDRESSES          ← (h2d'00')(h2d'C0')(h2d'94')(h2d'D4')
    ⍝ Row offsets to move curser
    :Field Private Shared ReadOnly ROW_OFFSETS             ← (h2d'00')(h2d'40')(h2d'14')(h2d'54')

    ⍝ ----------------------------------------------------------------------
    ⍝ Member Objects
    ⍝

    :Field Public MCP             ⍝ MCP23017 instance bound to the actual LCD

    ⍝ ----------------------------------------------------------------------
    ⍝ Member Variables
    ⍝

    ⍝ Construct some display commands (state buffer)
    :Field Private Displayshift   ← LCD_CURSORMOVE b8OR LCD_MOVERIGHT
    :Field Private Displaymode    ← LCD_ENTRYLEFT  b8OR LCD_ENTRYSHIFTDECREMENT
    :Field Private Displaycontrol ← LCD_DISPLAYON  b8OR LCD_CURSOROFF b8OR LCD_BLINKOFF

    ⍝ Port state buffer
    :Field Private PortA           ⍝ State buffer of Port A register
    :Field Private PortB           ⍝ State buffer of Port B register
    :Field Private DDRB            ⍝ State buffer of data direction register B

    ⍝ Display properties
    :Field Private CurrLine ← 0   ⍝ Current line that gets next char output
    :Field Private NumLines ← 2   ⍝ Number of display lines of the attached display 
    :Field Private NumCols  ← 16  ⍝ Number of display columns of attached display

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
    ∇ make3(addr backlight debug);c;initdata
      :Implements Constructor
      :Access Public
     
        ⍝ Instantiate Port Expander
      MCP←⎕NEW #.MCP23017 addr
     
        ⍝ I2C is relatively slow. MCP output port states are cached
        ⍝ so we don't need to constantly poll-and-change bit states.
      PortA PortB DDRB←0 0(h2d'02')
     
        ⍝ Set initial backlight color as 8 bit boolean array
        ⍝ to the inverse of the default ON
      c←b8NOT backlight
        ⍝ Post backlight value to output register cache
        ⍝ Color Bit 0 and 1 are connected to PortA Bit 6 and 7
        ⍝ Color Bit 2 is connected to PortB Bit 0
      PortA←(PortA b8AND(b2d'00111111'))b8OR(2 b8LSR(c b8AND(b2d'0000011')))
      PortB←(PortB b8AND(b2d'11111110'))b8OR(2 b8LSR(c b8AND(b2d'0000100')))
     
        ⍝ Set MCP23017 IOCON register to Bank 0 with sequential operation.
        ⍝ If chip is already set for Bank 0, this will just write to OLATB
        ⍝ which won't seriously bother anything on the plate right now
        ⍝ (blue backlight LED will come on, but that's done in the next
        ⍝ step anyway).
      _LOG MCP.WriteBytes MCP23017_IOCON_BANK1(0)
     
        ⍝ Brute force reload ALL registers to known state.
        ⍝ This also sets up all the input pins, pull-ups, etc. for the Pi Plate.
        ⍝ Assemble data block to write to MCP
      initdata←b2d'00111111'   ⍝ IODIRA    R+G LEDs=outputs, buttons=inputs
      initdata,←DDRB           ⍝ LCD       D7=input, Blue LED=output
      initdata,←b2d'00111111'  ⍝ IPOLA     Invert polarity on button inputs
      initdata,←b2d'00000000'  ⍝ IPOLB
      initdata,←b2d'00000000'  ⍝ GPINTENA  Disable interrupt-on-change
      initdata,←b2d'00000000'  ⍝ GPINTENB
      initdata,←b2d'00000000'  ⍝ DEFVALA
      initdata,←b2d'00000000'  ⍝ DEFVALB
      initdata,←b2d'00000000'  ⍝ INTCONA
      initdata,←b2d'00000000'  ⍝ INTCONB
      initdata,←b2d'00000000'  ⍝ IOCON
      initdata,←b2d'00000000'  ⍝ IOCON
      initdata,←b2d'00111111'  ⍝ GPPUA     Enable pull-ups on buttons
      initdata,←b2d'00000000'  ⍝ GPPUB
      initdata,←b2d'00000000'  ⍝ INTFA
      initdata,←b2d'00000000'  ⍝ INTFB
      initdata,←b2d'00000000'  ⍝ INTCAPA
      initdata,←b2d'00000000'  ⍝ INTCAPB
      initdata,←PortA          ⍝ GPIOA
      initdata,←PortB          ⍝ GPIOB
      initdata,←PortA          ⍝ OLATA
      initdata,←PortB          ⍝ OLATB
        ⍝ Write init data to MCP
        ⍝ Blockwrite of configuration data to address 0 (IODIRA) onwards
      _LOG MCP.WriteBytes 0(initdata)
     
        ⍝ Switch to Bank 1 and disable sequential operation.
        ⍝ From this point forward, the register addresses do NOT match
        ⍝ the list immediately above.  Instead, use the constants defined
        ⍝ at the start of the class.  Also, the address register will no
        ⍝ longer increment automatically after this -- multi-byte
        ⍝ # operations must be broken down into single-byte calls.
      _LOG MCP.WriteBytes MCP23017_IOCON_BANK0(b2d'10100000')
     
        ⍝ Initialize display
      _LOG WriteData h2d'33'            ⍝ 0x33 - Init
      _LOG WriteData h2d'32'            ⍝ 0x32 - Init
      _LOG WriteData h2d'28'            ⍝ 0x28 - 2 line 5x8 matrix
      _LOG WriteData LCD_CLEARDISPLAY
      _LOG WriteData LCD_CURSORSHIFT b8OR Displayshift
      _LOG WriteData LCD_ENTRYMODESET b8OR Displaymode
      _LOG WriteData LCD_DISPLAYCONTROL b8OR Displaycontrol
      _LOG WriteData LCD_RETURNHOME
     
      _LOG'Adafruit Char LCD Plate at address ',⍕addr,'with Debug',(('OFF' 'ON')[debug+1]),'and backlight b',⍕backlight,' is alive.'
    ∇

    ⍝ ----------------------------------------------------------------------
    ⍝ Write operations
    ⍝

    ⍝ The LCD data pins (D4-D7) connect to MCP pins 12-9 (PORTB4-1), in
    ⍝ that order. Because this sequence is 'reversed,' a direct shift
    ⍝ won't work. This table remaps 4-bit data values to MCP PORTB
    ⍝ outputs, incorporating both the reverse and shift.
    ⍝ Usage: flip[1+2⊥ _bAarray2flip_ ]
    flip ←(b2d'00000000')(b2d'00010000')(b2d'00001000')(b2d'00011000')
    flip,←(b2d'00000100')(b2d'00010100')(b2d'00001100')(b2d'00011100')
    flip,←(b2d'00000010')(b2d'00010010')(b2d'00001010')(b2d'00011010')
    flip,←(b2d'00000110')(b2d'00010110')(b2d'00001110')(b2d'00011110') 

    ⍝ Low-level 4-bit interface for LCD output.  This doesn't actually
    ⍝ write data, just returns an array of boolean arrays of the PORTB state over time.
    ⍝ Can concatenate the output of multiple calls (up to 8) for more
    ⍝ efficient batch write.
    ∇ r←out4(bitmask value);lo;hi
      hi←bitmask b8OR flip[1+(h2d'0F')b8AND 4 b8LSR value]
      lo←bitmask b8OR flip[1+(h2d'0F')b8AND value]
      r←(hi b8OR b2d'00100000')hi(lo b8OR b2d'00100000')lo
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
      :If 0≢(DDRB b8AND b2d'00000010')
          _LOG'Initiate Busy Flag Poll'
            ⍝ Preserve Blue LED pin
          lo←(PortB b8AND(b2d'00000001'))b8OR(b2d'01000000')
            ⍝ E=1 (strobe)
          hi←lo b8OR(b2d'00100000')
            ⍝ Write
          _LOG MCP.WriteBytes MCP23017_GPIOB(lo)
     
            ⍝ Poll LCD busy flag
          :Repeat
                ⍝ Strobe high (enable)
              _LOG MCP.WriteBytes MCP23017_GPIOB(hi)
                ⍝ First nybble contains busy state
              funret bits funerr←MCP.ReadBytes MCP23017_GPIOB(0)
                ⍝ Strobe low, high, low. Second nybble (A3) is ignored.
              _LOG MCP.WriteBytes MCP23017_GPIOB(lo hi lo)
              PortB←lo
            ⍝ D7=0,not busy
          :Until 0≡(bits b8AND(b2d'00000010'))
          _LOG'Poll completed'
     
            ⍝  Polling complete, change D7 pin to output
          DDRB←DDRB b8AND(b2d'11111101')
          _LOG MCP.WriteBytes MCP23017_IODIRB(DDRB)
      :Else
          _LOG'No Poll required'
      :EndIf
     
        ⍝ Mask out PORTB LCD control bits
      bitmask←PortB b8AND(b2d'00000001')
      :If charmode
            ⍝ Set data bit if not a command
          bitmask←bitmask b8OR(b2d'10000000')
            ⍝ Convert string into value array
            ⍝ value←¯1+⎕AV⍳value
          value←'UTF-8'⎕UCS value
      :EndIf
     
        ⍝ Values will be processed by out4 (flip and hi/lo strobe)
        ⍝ Finally remove enclosure and catenate the boolean arrays
        ⍝ 'data' now holds an array of bytes to be sent in chunks of 32 bytes
        ⍝ to MCP device
      data←,↑{out4 bitmask ⍵}¨value
     
        ⍝ Set PortB to last byte that will be send
      PortB←⊃¯1↑data
     
        ⍝ Write data split into 32 bytes chunks
        ⍝ Loop runs as long as there are data bytes to send
      :While (⍴data)≠0
            ⍝ Check if we still have 32 or more bytes left
          :If (⍴data)≥32
                ⍝ Send 32 bytes and drop them from queue afterwards
              _LOG'Send 32 bytes'
              _LOG MCP.WriteBytes MCP23017_GPIOB(32↑data)
              data←32↓data
          :Else
                ⍝ Last chunk is less then 32 bytes
                ⍝ Send and drop them after send
              _LOG'Send ',(⍕⍴data),' bytes'
              _LOG MCP.WriteBytes MCP23017_GPIOB data
              data←⍬
          :EndIf
      :EndWhile
     
        ⍝ If a poll-worthy instruction was issued, reconfigure D7
        ⍝ pin as input to indicate need for polling on next call.
      :If (~charmode)∧(1↑value)∊pollables
          _LOG'Set Poll indicator'
          DDRB←DDRB b8OR(b2d'00000010')
          _LOG MCP.WriteBytes MCP23017_IODIRB(DDRB)
      :EndIf
     
      r←0
    ∇

    ⍝ ----------------------------------------------------------------------
    ⍝ Destructor
    ⍝
    ∇ close;r;initdata
      :Implements Destructor
      _LOG'Adafruit Char LCD Plate at address ',⍕MCP.DeviceAddress,'will be closed.'
     
        ⍝ Puts the MCP23017 back in Bank 0 + sequential write mode
      _LOG MCP.WriteBytes MCP23017_IOCON_BANK1(0)
     
        ⍝ Turn off LEDs on the way out
      PortA←b2d'11000000'
      PortB←b2d'00000001'
     
        ⍝ Sleep 0.0015 sec
      ⎕DL 0.0015
     
        ⍝ Brute force reload ALL registers to known state.
        ⍝ This also sets up all the input pins, pull-ups, etc. for the Pi Plate.
        ⍝ Assemble data block to write to MCP
      initdata←b2d'00111111'   ⍝ IODIRA    R+G LEDs=outputs, buttons=inputs
      initdata,←DDRB           ⍝ LCD       D7=input, Blue LED=output
      initdata,←b2d'00111111'  ⍝ IPOLA     Invert polarity on button inputs
      initdata,←b2d'00000000'  ⍝ IPOLB
      initdata,←b2d'00000000'  ⍝ GPINTENA  Disable interrupt-on-change
      initdata,←b2d'00000000'  ⍝ GPINTENB
      initdata,←b2d'00000000'  ⍝ DEFVALA
      initdata,←b2d'00000000'  ⍝ DEFVALB
      initdata,←b2d'00000000'  ⍝ INTCONA
      initdata,←b2d'00000000'  ⍝ INTCONB
      initdata,←b2d'00000000'  ⍝ IOCON
      initdata,←b2d'00000000'  ⍝ IOCON
      initdata,←b2d'00111111'  ⍝ GPPUA     Enable pull-ups on buttons
      initdata,←b2d'00000000'  ⍝ GPPUB
      initdata,←b2d'00000000'  ⍝ INTFA
      initdata,←b2d'00000000'  ⍝ INTFB
      initdata,←b2d'00000000'  ⍝ INTCAPA
      initdata,←b2d'00000000'  ⍝ INTCAPB
      initdata,←PortA          ⍝ GPIOA
      initdata,←PortB          ⍝ GPIOB
      initdata,←PortA          ⍝ OLATA
      initdata,←PortB          ⍝ OLATB
        ⍝ Write init data to MCP
        ⍝ Blockwrite of configuration data to address 0 (IODIRA) onwards
      _LOG MCP.WriteBytes 0(initdata)
     
        ⍝ Deconstruct MCP23017 instance
      MCP←⍬
      r←0
    ∇

    ⍝ ----------------------------------------------------------------------
    ⍝ Utility methods
    ⍝

    ⍝ Set limits of attached display (Default set to cols:16 lines:2)
    ∇ r←Begin(cols lines)
      :Access Public
      CurrLine←0
      NumLines←lines
      NumCols←cols
      r←Clear
    ∇

    ⍝ Whipe display content
    ∇ r←Clear
      :Access Public
      r←WriteData LCD_CLEARDISPLAY
    ∇

    ⍝ Move cursor to home position (col:1 row:1)
    ∇ r←Home
      :Access Public
      r←WriteData LCD_RETURNHOME
    ∇

    ⍝ Set cursor to given position (guarded by values set by .Begin)
    ∇ r←SetCursor(col row)
      :Access Public
     
        ⍝ Guard given LCD limits
      row←{⍵<1:1 ⋄ ⍵>NumLines:NumLines ⋄ ⍵}row
      col←{⍵<1:1 ⋄ ⍵>NumLines:NumCols ⋄ ⍵}col
     
        ⍝ Set DDRAM address to new postion
      r←WriteData LCD_SETDDRAMADDR b8OR(col+ROW_OFFSETS[row]-1)
    ∇

    ⍝ Turn the display on (quickly)
    ∇ r←DisplayOn
      :Access Public
      Displaycontrol←Displaycontrol b8OR LCD_DISPLAYON
      r←WriteData Displaycontrol b8OR LCD_DISPLAYCONTROL
    ∇

    ⍝ Turn the display off (quickly)
    ∇ r←DisplayOff
      :Access Public
      Displaycontrol←Displaycontrol b8AND b8NOT LCD_DISPLAYON
      r←WriteData Displaycontrol b8OR LCD_DISPLAYCONTROL
    ∇

    ⍝ Turn underline cursor on
    ∇ r←CursorOn
      :Access Public
      Displaycontrol←Displaycontrol b8OR LCD_CURSORON
      r←WriteData Displaycontrol b8OR LCD_DISPLAYCONTROL
    ∇

    ⍝ Turn underline cursor off
    ∇ r←CursorOff
      :Access Public
      Displaycontrol←Displaycontrol b8AND b8NOT LCD_CURSORON
      r←WriteData Displaycontrol b8OR LCD_DISPLAYCONTROL
    ∇

    ⍝ Toggles the underline cursor On/Off
    ∇ r←ToggleCursor
      :Access Public
      Displaycontrol←Displaycontrol b8XOR LCD_CURSORON
      r←WriteData Displaycontrol b8OR LCD_DISPLAYCONTROL
    ∇

    ⍝ Turn on the blinking cursor
    ∇ r←BlinkOn
      :Access Public
      Displaycontrol←Displaycontrol b8OR LCD_BLINKON
      r←WriteData Displaycontrol b8OR LCD_DISPLAYCONTROL
    ∇

    ⍝ Turn off the blinking cursor
    ∇ r←BlinkOff
      :Access Public
      Displaycontrol←Displaycontrol b8AND b8NOT LCD_BLINKON
      r←WriteData Displaycontrol b8OR LCD_DISPLAYCONTROL
    ∇

    ⍝ Toggles the blinking cursor On/Off
    ∇ r←ToggleBlink
      :Access Public
      Displaycontrol←Displaycontrol b8XOR LCD_BLINKON
      r←WriteData Displaycontrol b8OR LCD_DISPLAYCONTROL
    ∇

    ⍝ These commands scroll the display without changing the RAM
    ⍝ Scroll to the left
    ∇ r←ScrollLeft
      :Access Public
      Displayshift←LCD_DISPLAYMOVE b8OR LCD_MOVELEFT
      r←WriteData Displayshift b8OR LCD_CURSORSHIFT
    ∇
    ⍝ Scroll to the right
    ∇ r←ScrollRight
      :Access Public
      Displayshift←LCD_DISPLAYMOVE b8OR LCD_MOVERIGHT
      r←WriteData Displayshift b8OR LCD_CURSORSHIFT
    ∇

    ⍝ This is for text that flows left to right
    ∇ r←LeftToRight
      :Access Public
      Displaymode←Displaymode b8OR LCD_ENTRYLEFT
      r←WriteData Displaymode b8OR LCD_ENTRYMODESET
    ∇

    ⍝ This is for text that flows right to left
    ∇ r←RightToLeft
      :Access Public
      Displaymode←Displaymode b8AND b8NOT LCD_ENTRYLEFT
      r←WriteData Displaymode b8OR LCD_ENTRYMODESET
    ∇

    ⍝ This will 'right justify' text from the cursor
    ∇ r←AutoscrollOn
      :Access Public
      Displaymode←Displaymode b8OR LCD_ENTRYSHIFTINCREMENT
      r←WriteData Displaymode b8OR LCD_ENTRYMODESET
    ∇

    ⍝ This will 'right justify' text from the cursor
    ∇ r←AutoscrollOff
      :Access Public
      Displaymode←Displaymode b8AND b8NOT LCD_ENTRYSHIFTINCREMENT
      r←WriteData Displaymode b8OR LCD_ENTRYMODESET
    ∇

⍝    def createChar(self, location, bitmap):
⍝        self.write(self.LCD_SETCGRAMADDR | ((location & 7) << 3))
⍝        self.write(bitmap, True)
⍝        self.write(self.LCD_SETDDRAMADDR)
    ⍝ Create custom char from bitmap (not tested yet)
    ∇ r←CreateChar(location bitmap)
      :Access Public
      r←WriteData LCD_SETCGRAMADDR b8OR 3 b8LSL location b8AND 7
      r,←WriteData bitmap
      r,←WriteData LCD_SETDDRAMADDR
    ∇

    ⍝ Send string to LCD. Newline (⎕UCS 13) wraps to next line
    ∇ r←Message(text truncate);lines;address;linelen
      :Access Public
        ⍝ Cut string into an array of string using ⎕UCS 13 (NewLine) as delimiter
      lines←(⎕UCS 13)Cut text
     
        ⍝ Handle truncate and send strings to display
      :For i :In ⍳⍴lines
            ⍝ Get DDRAN offset and set address for actual line
          address←LINE_ADDRESSES[i]
          r←WriteData address
            ⍝ Get length of of actual line for truncate handling
          linelen←⍴⊃lines[i]
     
            ⍝ Handle truncate
          :If (truncate=TRUNCATE)∧(linelen>NumCols)
                ⍝ Hard truncate of line
              r,←WriteChar NumCols↑⊃lines[i]
          :ElseIf (truncate=TRUNCATE_ELLIPSIS)∧(linelen>NumCols)
                ⍝ Nicer truncate with ellipsis
              r,←WriteChar((NumCols-3)↑⊃lines[i]),'...'
          :Else
                ⍝ Write line without truncation
              r,←WriteChar⊃lines[i]
          :EndIf
      :EndFor
    ∇

⍝  Set Backlight color 1:Red 2:Green 4:Blue (Add values to mix colors)
    ∇ r←Backlight color;c;funret1;funval1;funerr1;funret2;funval2;funerr2
      :Access Public
      c←b8NOT color
        ⍝ Post backlight value to output register cache
        ⍝ Color Bit 0 and 1 are connected to PortA Bit 6 and 7
        ⍝ Color Bit 2 is connected to PortB Bit 0
      PortA←(PortA b8AND(b2d'00111111'))b8OR(2 b8LSR(c b8AND(b2d'0000011')))
      PortB←(PortB b8AND(b2d'11111110'))b8OR(2 b8LSR(c b8AND(b2d'0000100')))
     
      funret1 funval1 funerr1←MCP.WriteBytes MCP23017_GPIOA(2⊥PortA)
      funret2 funval2 funerr2←MCP.WriteBytes MCP23017_GPIOB(2⊥PortB)
      r←(funret1 funval1 funerr1)(funret2 funval2 funerr2)
    ∇

    ⍝ Read state of single button
    ∇ r←ButtonPressed b;funret;bits;funerr
      :Access Public
        ⍝ Read button states
      funret bits funerr←MCP.ReadBytes MCP23017_GPIOA(0)
        ⍝ Select and mask button state
      r←1 b8AND b b8LSR bits
    ∇

    ⍝ Read and return bitmask of combined button state
    ∇ r←Buttons;funret;bits;funerr
      :Access Public
        ⍝ Read button states
      funret bits funerr←MCP.ReadBytes MCP23017_GPIOA(0)
        ⍝ Select and mask state of all buttons
      r←(b2d'00011111')b8AND bits
    ∇

    ⍝ ----------------------------------------------------------------------
    ⍝ Test code
    ⍝
    ∇ Test;lcd;col;btn;prev
      :Access Public Shared
      lcd←⎕NEW ##.CharLCDPlate
      {}lcd.Begin 16 2
      {}lcd.Clear
      {}lcd.Message('Adafruit RGB LCD',(⎕UCS 13),'Plate w/Keypad!')0
      ⎕DL 1
     
      col←('Red'RED)('Yellow'YELLOW)('Green'GREEN)
      col,←('Teal'TEAL)('Blue'BLUE)('Violet'VIOLET)
      col,←('Off'OFF)('On'ON)
     
      ⎕←'Cycle thru backlight colors'
      :For c :In col
          ⎕←c[1]
          {}lcd.Clear
          {}lcd.Message(⊃c[1])0
          {}lcd.Backlight c[2]
          ⎕DL 0.5
      :EndFor
     
      btn←(⊂SELECT'Select'ON)
      btn,←(⊂LEFT'Left'RED)
      btn,←(⊂UP'Up'BLUE)
      btn,←(⊂DOWN'Down'GREEN)
      btn,←(⊂RIGHT'Right'VIOLET)
     
      ⎕←'Try buttons on plate'
      {}lcd.Clear
      {}lcd.Message'Try buttons' 0
     
      prev←¯1
      :While prev≠SELECT
          :For b :In btn
              :If lcd.ButtonPressed b[1]
                  :If b[1]≠prev
                      ⎕←b[2]
                      {}lcd.Clear
                      {}lcd.Message(⊃b[2])0
                      {}lcd.Backlight b[3]
                      prev←b[1]
                  :EndIf
              :EndIf
          :EndFor
      :EndWhile
      ⎕←'Select detected - Exit'
    ∇

:EndClass


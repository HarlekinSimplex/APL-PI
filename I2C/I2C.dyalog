:Class I2C
⍝ Raspberry I2C bus handler class
⍝ 2015 Stephan Becker

    ⍝ Set environment
    ⎕IO←⎕ML←1

    ⍝ Member objects
    :Field Opened ← 0 
    :Field BusID  ← 1    ⍝ Default BusID (should be derived from PI version)

    ⍝ Constructor methods
    ∇ make;r;funret;funerr
      :Implements Constructor
      :Access Public
        ⍝ Associate I2C library functions
        ⍝ Bus handling
      '_Open'⎕NA'I libi2c-com.so|OpenI2C I I =I'
      '_Close'⎕NA'I libi2c-com.so|CloseI2C =I'
     
        ⍝ Byte handling (numbers)
      '_WriteBytes'⎕NA'I libi2c-com.so|WriteBytes I =#U1[] =I'
      '_WriteChar'⎕NA'I libi2c-com.so|WriteBytes I =#C =I'
     
        ⍝ Byte handling (Characters)
      '_ReadBytes'⎕NA'I libi2c-com.so|ReadBytes I =#U1 =I'
      '_ReadChar'⎕NA'I libi2c-com.so|ReadBytes I =#C =I'
     
        ⍝ Pi Revision 0/1 → BusID←0
        ⍝ Pi Revision 2 → BusID←1
      :If getPiRevision<2
          BusID←0
      :Else
          BusID←1
      :EndIf
     
        ⍝ Open I2C bus
      r←OpenBus
     
      ⎕←'I2C Bus with ID=',⍕BusID,'is now alive.'
    ∇

    ⍝ Get Pi Revision from /proc/cpuinfo
    ∇ r←getPiRevision;tie;cpuinfo;bin;rev
        ⍝ Open file cpuinfo and read chars in 100 byte chunks until EOF
      tie←('/proc/','cpuinfo')⎕NTIE 0
      cpuinfo←{r←⎕NREAD ⍵ 80 100 ⋄ 0=⍴r:r ⋄ r,∇ ⍵}tie
     
        ⍝ Partition into an array of strings
      bin←~cpuinfo∊⎕UCS 13 10
      cpuinfo←↑bin{⎕ML←3 ⋄ ⍺⊂⍵}cpuinfo
     
        ⍝ Find 'Revison' entry and capture revison value
        ⍝ Find, cut and tdiy up Revison Entry
      rev←,(∨/[2]'Revision'⍷cpuinfo)/[1]cpuinfo
     
        ⍝ Check if Revison was found
      :If 0=⍴rev
            ⍝ Return Revision 0
          r←0
      :Else
            ⍝ Clean up and extract Revison Entry
          rev←(~rev∊' '(⎕UCS 9))/rev
          rev←1↓⊃(rev=':')⊂rev
     
            ⍝ Check Revision
          :If ∨/(⊂rev)≡¨('0000' '0002' '0003')
                ⍝ If RevisionID=0/2/3 return Revision 1
              r←1
          :Else
                ⍝ Return Revision 2
              r←2
          :EndIf
      :EndIf
    ∇

    ⍝ Retriev actual I2C bus ID 
    ∇ r←getBusID
      :Access Public
      r←BusID
    ∇

    ⍝ Retriev actual bus status
    ∇ r←getOpened
      :Access Public
      r←Opened
    ∇

    ⍝ Open I2C bus  
    ∇ r←OpenBus
      :Access Public
      r←0 0
      :If Opened≠1
          Opened←1
          r←_Open BusID 0 0
      :EndIf
    ∇

    ⍝ Close I2C bus  
    ∇ r←CloseBus
      :Access Public
      r←0
      :If Opened=1
          Opened←0
          r←_Close 0
      :EndIf
    ∇

    ⍝ Read / Write data from / to I2C bus
    ⍝ Wrapper for I2C interface lib calls
    ⍝ Write
    ∇ r←WriteBytes(device register buffer)
      :Access Public
      r←_WriteBytes(1↑∊device)(∊register,buffer)0
    ∇
    ∇ r←WriteChar(device register buffer)
      :Access Public
      r←_WriteChar(1↑∊device)(∊register,buffer)0
    ∇
    ⍝ Read
    ∇ r←ReadBytes(device register buffer)
      :Access Public
      r←_WriteBytes(1↑∊device)(∊register)0
      r←_ReadBytes(1↑∊device)(∊buffer)0
    ∇
    ∇ r←ReadChar(device register buffer)
      :Access Public
      r←_WriteBytes(1↑∊device)(∊register)0
      r←_ReadChar(1↑∊device)(∊buffer)0
    ∇

    ⍝ Destructor method
    ∇ close;r
      :Implements Destructor
      ⎕←'I2C Bus with ID=',⍕BusID,'will be closed.'
      ⍝ Close I2C bus
      :If Opened
          r←CloseBus
      :EndIf
        ⍝ Unload shared I2C interface library
      :If 0≠⍴fns←⎕NL ¯3.6
          r←_Close 0
          ⎕EX fns ⍝ Unload the DLL by expunging all
          r←0
      :EndIf
    ∇

:EndClass

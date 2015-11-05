:Class I2C
⍝ Raspberry I2C bus wrapper

    :Field Opened ← 0 
    :Field BusID  ← 1

    ∇ r←getBusID
      :Access Public
      r←BusID
    ∇

    ∇ r←OpenBus busid
      :Access Public
      BusID←1↑,busid
      Opened←1
      r←_Open BusID 0 0
    ∇

    ∇ r←CloseBus
      :Access Public
      Opened←0
      r←_Close 0
    ∇

    ∇ r←WriteBytes(device buffer)
      :Access Public
      r←_WriteBytes(1↑,device)(,buffer)0
    ∇

    ∇ r←WriteChar(device buffer)
      :Access Public
      r←_WriteChar(1↑,device)(,buffer)0
    ∇

    ∇ r←ReadBytes(device buffer)
      :Access Public
      r←_ReadBytes(1↑,device)(,buffer)0
    ∇

    ∇ r←ReadChar(device buffer)
      :Access Public
      r←_ReadChar(1↑,device)(,buffer)0
    ∇

    ∇ make;r
      :Implements Constructor
      :Access Public
      r←AssociateI2CFunctions
      ⎕←'I2C Bus with ID=',⍕BusID,'is now alive.'
    ∇

    ∇ close;r
      :Implements Destructor
      ⎕←'I2C Bus with ID=',⍕BusID,'will be closed.'
      r←UnAssociateI2CFunctions
    ∇

    ∇ r←AssociateI2CFunctions
        ⍝ Associate I2C library functions
        ⍝ Bus handling
      '_Open'⎕NA'I libi2c-com.so|OpenI2C I I =I'
      '_Close'⎕NA'I libi2c-com.so|CloseI2C =I'
     
        ⍝ Byte handling (numbers)
      '_WriteBytes'⎕NA'I libi2c-com.so|WriteBytes I <#U1[] =I'
      '_WriteChar'⎕NA'I libi2c-com.so|WriteBytes I <#C    =I'
     
        ⍝ Byte handling (Characters)
      '_ReadBytes'⎕NA'I libi2c-com.so|ReadBytes I =#U1 =I'
      '_ReadChar'⎕NA'I libi2c-com.so|ReadBytes I =#C =I'
     
      r←1
    ∇

    ∇ r←UnAssociateI2CFunctions;fns
      :If Opened
          r←CloseBus
      :EndIf
      :If 0≠⍴fns←⎕NL ¯3.6
          r←_Close 0
          ⎕EX fns ⍝ Unload the DLL by expunging all
          r←0
      :EndIf
    ∇

:EndClass

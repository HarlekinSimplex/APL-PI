:Class I2C
    :Field Opened ← 0 
    :Field BusID  ← 1

    ∇ r←OpenBus busid;funret;funerr
      :Access Public
      BusID←1↑,busid
      Opened←1
      r←_Open BusID 0 0
    ∇

    ∇ r←CloseBus;funret;funerr
      :Access Public
      Opened←0
      r←_Close 0
    ∇

    ∇ r←WriteBytes(device buffer);funret;funerr
      :Access Public
      r←_WriteBytes(1↑,device)(,buffer)0
    ∇

    ∇ r←WriteChar(device buffer);funret;funerr
      :Access Public
      r←_WriteChar(1↑,device)(,buffer)0
    ∇

    ∇ r←ReadBytes(device buffer);funret;funval;funerr
      :Access Public
      r←_ReadBytes(1↑,device)(,buffer)0
    ∇

    ∇ r←ReadChar(device buffer);funret;funval;funerr
      :Access Public
      r←_ReadChar(1↑,device)(,buffer)0
    ∇

    ∇ make;r
      :Implements Constructor
      :Access Public
      ⎕←'I2C Bus with ID=',⍕BusID,'is now alive.'
      r←AssociateI2CFunctions 0
    ∇

    ∇ close;r
      :Implements Destructor
      ⎕←'I2C Bus with ID=',⍕BusID,'was closed.'
      r←UnAssociateI2CFunctions 0
    ∇

    ∇ r←AssociateI2CFunctions dummy
      '_Open'⎕NA'I libi2c-com.so|OpenI2C    I I =I'
      '_Close'⎕NA'I libi2c-com.so|CloseI2C   =I'
     
      '_WriteBytes'⎕NA'I libi2c-com.so|WriteBytes I <#U1[] =I'
      '_WriteChar'⎕NA'I libi2c-com.so|WriteBytes I <#C    =I'
⍝       '_WriteArray'⎕NA'I libi2c-com.so|WriteBytes I <U1[]  =I'
     
      '_ReadBytes'⎕NA'I libi2c-com.so|ReadBytes  I =#U1   =I'
      '_ReadChar'⎕NA'I libi2c-com.so|ReadBytes  I =#C    =I'
⍝       '_ReadArray' ⎕NA'I libi2c-com.so|ReadBytes  I =U1[]  =I'
     
      r←1
    ∇

    ∇ r←UnAssociateI2CFunctions dummy;fns
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


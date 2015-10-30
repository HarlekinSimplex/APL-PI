:Namespace I2C
    ⍝ Converted from the quick2wire-python-api
    ⍝ For more information see https://github.com/quick2wire/quick2wire-python-api

    ReadBufferSize←255

    ∇ r←Init dummy
      'Open'⎕NA'I libi2c-com.so|OpenI2C I I =I'                 ⍝ bus, extra_open_flags, err
      'Close'⎕NA'I libi2c-com.so|CloseI2C =I'                   ⍝ err

      'WriteBytes'⎕NA'I libi2c-com.so|WriteBytes I <#U1[] =I'   ⍝ address, input_bytes[], err
      'WriteChar'⎕NA'I libi2c-com.so|WriteBytes  I <#C    =I'   ⍝ address, input_bytes[], err
⍝      'WriteArray'⎕NA'I libi2c-com.so|WriteBytes I <U1[]  =I'   ⍝ address, input_bytes[], err

      'ReadBytes' ⎕NA'I libi2c-com.so|ReadBytes  I =#U1  =I'  ⍝ address, output_buffer[], err
      'ReadChar'  ⎕NA'I libi2c-com.so|ReadBytes  I =#C   =I'  ⍝ address, output_buffer[], err
⍝      '__ReadArray' ⎕NA'I libi2c-com.so|ReadBytes  I =U1[] =I'  ⍝ address, output_buffer[], err

      'APLTestWriteChar' ⎕NA'I libi2c-com.so|APLTestWrite <#C'  
      'APLTestWriteBytes'⎕NA'I libi2c-com.so|APLTestWrite <#U1'
      'APLTestReadChar'  ⎕NA'I libi2c-com.so|APLTestRead  =#C'     
      'APLTestReadBytes' ⎕NA'I libi2c-com.so|APLTestRead  =#U1'

      r←0
    ∇

⍝    ∇ r←ReadBytes (Address ErrorCode)
⍝       r←__ReadBytes Address (ReadBufferSize⍴0) ErrorCode   ⍝ Default would be a byte counted array of 255 zeros
⍝    ∇

⍝    ∇ r←ReadChar (Address ErrorCode)
⍝        r←__ReadChar Address (ReadBufferSize⍴'') ErrorCode  ⍝ same as with bytes
⍝    ∇

⍝    ∇ r←ReadArray (Address ErrorCode)
⍝        r←__ReadArray Address ????? ⊂ErrorCode            ⍝ No clue what this may be
⍝    ∇
 
    ∇ r←UnInit dummy;fns
      :If 0≠⍴fns←⎕NL ¯3.6
          r←Close 0
          ⎕EX fns ⍝ Unload the DLL by expunging all
          r←0
      :EndIf
    ∇

:EndNamespace

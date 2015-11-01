:Namespace I2CTests
	
	⍝ Dependencies
	⍝∇:require =/I2C
	
	I2C_BUS←1
        I2C_DEVICE ←(2×16)+1  ⍝ 0x21

        IODIRA     ←(0×16)+0  ⍝ 0x00
        IODIRB     ←(0×16)+1  ⍝ 0x01
        GPIOA      ←(1×16)+2  ⍝ 0x12
        GPIOB      ←(1×16)+3  ⍝ 0x13
        OLATA      ←(1×16)+4  ⍝ 0x14
        OLATB      ←(1×16)+5  ⍝ 0x15
	
	∇ ret←GPIORegisterReadWriteTest i;ret;funret;funout;funerr;msg
		ret←0
		
                ⍝ Read current value of GPIOB
                ⍝ Set ReadPointer to GPIOB and read one byte
                funret funerr ← #.I2C.WriteBytes I2C_DEVICE GPIOB 0
		funret funout funerr ← #.I2C.ReadBytes I2C_DEVICE 0 0

                ⍝ Log result
		msg←'Value at GPIORegister is ',(⍕funout),'. Setting it to ',(⍕i),':'
		
                ⍝ Write new value to GPIOB
		funret funerr ← #.I2C.WriteBytes I2C_DEVICE (GPIOB i) 0

                ⍝ Read updated value of GPIOB
                ⍝ Set ReadPointer to GPIOB and read one byte
                funret funerr ← #.I2C.WriteBytes I2C_DEVICE GPIOB 0
		funret funout funerr ← #.I2C.ReadBytes I2C_DEVICE 0 0

                ⍝ If read data read matches given value the log 'Success'
                ⍝ otherwise log 'Failure'
		:IF funout≡i
			msg,←' Success'
		:Else
			msg,←' Failure'
			ret←1
		:EndIf
		
		⎕←msg
	∇
	
	∇ ret←GPIORegisterReadWriteTests;ret;funret;funerr
		ret←0
		
		funret funerr ← #.I2C.Open I2C_BUS 0 0
		:If funret≢0
			ret←funerr
			→clean
		:EndIf
		
                ⍝ Set all GPIOB pins as output
		funret funerr ← #.I2C.WriteBytes I2C_DEVICE (IODIRB 0) 0

                ⍝ Count from 0 to x and set GPIOB pins accordingly 
		{funret funerr ← GPIORegisterReadWriteTest ⍵ ⋄ ⎕DL 0.1}¨⍳15

                ⍝ Set all GPIOB pins to low
		funret funerr ← #.I2C.WriteBytes I2C_DEVICE (GPIOB 0) 0
		
		clean:         
                ⍝ Close I2C bus
		funret funerr ← #.I2C.Close 0
	∇
	
	∇ ret←main;ret;funret
		ret←0
		
                ⍝ Load and assign I2C interface library
                funret ← #.I2C.Init 0  

		⍝ Run Tests
		funret ← GPIORegisterReadWriteTests

                ⍝ Unload I2C library
                funret ← #.I2C.UnInit 0
	∇

        ∇ ret←test ;funret;funout;funerr
               ret←0

               I2C_DEVICE ←(2×16)+1  ⍝ 0x21
               IODIRA     ←(0×16)+0  ⍝ 0x00
               IODIRB     ←(0×16)+1  ⍝ 0x01
               GPIOA      ←(1×16)+2  ⍝ 0x12
               GPIOB      ←(1×16)+3  ⍝ 0x13
               OLATA      ←(1×16)+4  ⍝ 0x14
               OLATB      ←(1×16)+5  ⍝ 0x15

               #.I2C.Init 0
               #.I2C.Open I2C_BUS 0 0
               #.I2C.WriteBytes I2C_DEVICE (IODIRA 0) 0
               #.I2C.WriteBytes I2C_DEVICE (GPIOA 85) 0
               #.I2C.WriteBytes I2C_DEVICE (IODIRB 0) 0
               #.I2C.WriteBytes I2C_DEVICE (GPIOB 170) 0
               ⎕←'Start Read'
               #.I2C.WriteBytes I2C_DEVICE OLATB 0
               #.I2C.ReadBytes I2C_DEVICE 0 0
               #.I2C.WriteBytes I2C_DEVICE OLATA 0
               #.I2C.ReadBytes I2C_DEVICE 0 0
               #.I2C.Close 0
               #.I2C.UnInit 0               
        ∇
:EndNamespace

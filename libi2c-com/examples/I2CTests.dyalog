:Namespace I2CTests
	⍝ Converted from the quick2wire-python-api
	⍝ For more information see https://github.com/quick2wire/quick2wire-python-api
	
	⍝ Dependencies
	⍝∇:require = '/home/pi/github/APL-PI/I2C/I2C.dyalog'
	
	I2C_BUS←1
	IODIR_REGISTER_B←1
	GPIO_REGISTER_B←19
	ADDRESS←33
	
	∇ ret←GPIORegisterReadWriteTest i;ret;funret;funout;funerr;msg
		ret←0
		
		funret funout funerr ← #.I2C.ReadBytes ADDRESS (,GPIO_REGISTER_B) (,1)
		msg←'Value at GPIORegister is ',(⍕funout),'. Setting it to ',(⍕i),':'
		
		funret funerr ← #.I2C.WriteBytes ADDRESS (GPIO_REGISTER_B i) 0
		funret funout funerr ← #.I2C.ReadBytes ADDRESS (,GPIO_REGISTER_B) (,1)
		:IF funout≡i
			msg,←' Success'
		:Else
			msg,←' Failure'
			ret←1
		:EndIf
		
		msg
	∇
	
	∇ ret←GPIORegisterReadWriteTests;ret;funret;funerr
		ret←0
		
		funret funerr ← #.I2C.Open I2C_BUS 0 0
		:If funret≢0
			ret←funerr
			→clean
		:EndIf
		
		funret funerr ← #.I2C.WriteBytes ADDRESS (IODIR_REGISTER_B 0) 0
		{funret funerr ← GPIORegisterReadWriteTest ⍵ ⋄ ⎕DL 0.1}¨⍳255
		funret funerr ← #.I2C.WriteBytes ADDRESS (GPIO_REGISTER_B 0) 0
		
		clean:         ⍝ Tidy Up
		funret funerr ← #.I2C.Close 0
	∇
	
	∇ ret←main;ret;funret
		ret←0
		
                ⍝ Load and assign I2C interface library
                #.I2C.Init 0  

		⍝	Tests
		funret←GPIORegisterReadWriteTests

                ⍝ Unload I2C library
                #.I2C.UnInit
	∇

        ∇ ret←test
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
               #.I2C.WriteBytes I2C_DEVICE (,IODIRA 0) (,0)
               #.I2C.WriteBytes I2C_DEVICE (,GPIOA 85) (,0)
               #.I2C.WriteBytes I2C_DEVICE (,IODIRB 0) (,0)
               #.I2C.WriteBytes I2C_DEVICE (,GPIOB 170) (,0)
               ⎕←'Start Read'
               #.I2C.ReadBytes I2C_DEVICE (OLATA) (,0)
               #.I2C.ReadBytes I2C_DEVICE (OLATB) (,0)
               #.I2C.Close 0
               #.I2C.UnInit 0               
        ∇
:EndNamespace

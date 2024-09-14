 LDX #$00
 LDY #$FF

swap:
 LDAA $0,X
 LDAB $0,Y
 STAA $0,Y
 STAB $0,X

 INX
 DEY
 
 CPX #128
 BNE swap

end:
 SWI
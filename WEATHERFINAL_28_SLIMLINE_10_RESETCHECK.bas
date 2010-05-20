' sgsweather code
' using multiple servers
' set hostlist as follows
' -----------
' 1) kryten: 109.74.204.206
' 2) sheeva: 93.97.184.163
' 3) pippin: 62.18.44.156
' -----------

#picaxe28x1
sertxd("Restarted",CR,LF)
read 0,b27
b27 = b27 + 1
write 0,b27
'symbol ADCON0 = $1f
wait 1
hi2csetup i2cmaster, %11010000, i2cslow, i2cbyte
'	hi2cout 0, ($0,$15, $11, $1, $2, $5, $08)
'	hi2cout $0E, (%00000000)
	pause 50


wait 3

serout 1,T2400,("A")
high 0


b27 = 0


timer = 0
settimer count 65535
timer = 0
b13 = 0
if input0 is on then 
b13 = 1 
endif



symbol cs = 3 ' chip select (out)
symbol cs2 = 4 'cs2

symbol sclk = 2 ' clock (output pin)
symbol serdata = input6 ' data (input pin for shiftin, note input7
symbol counter = b14 ' variable used during loop
'symbol mask = w9 ' bit masking variable
symbol var_in = w10 ' data variable used during shiftin
symbol bits = 12 ' number of bits
symbol MSBvalue = 2048 ' MSBvalue
symbol pgaCS = 7
symbol adout = 6


high cs
high cs2


symbol timep = 15		'period between readings (must be multiple of 60)




'variables


'b11	 - next reading
'b13	 - rain start position
'b0-b5 - changed in clock BCD	(temp)
'b7	 - used in BCD convertion (temp)
'b12	 - used for next time wait (temp)
'b27	 - valid time flag


read 0,b1
if b1 > 38 then resetlimitreached


'calculate next reading
gosub calculatenext

sertxd("goto readings\n\n")
gosub readings
if b23 = 0 then gosub readings
sertxd("return readings \n\n")




main:
sertxd("main\n")

waits:

'i2cslave %11010000, i2cslow, i2cbyte

hi2cin 1,(b1)						'get time (mins)
gosub bcd_decimal
if b27 <> 0 then alt_time




b12 = b11 - b1
if b12 > 14 then gosub tenleft
if b27 <> 0 then alt_time



b12 = b11 - b1
if b12 > 10 then gosub fiveleft
if b27 <> 0 then alt_time

		

b12 = b11 - b1
if b12 > 5 then gosub twoleft
if b27 <> 0 then alt_time




b12 = b11 - b1
if b12 > 1 then gosub oneleft
if b27 <> 0 then alt_time

if b1 = 0 then
if b11 = 60 then rittime
else
b12 = b11 - b1
end if


hi2cin 1,(b1)						'get time (mins)
gosub bcd_decimal
if b27 <> 0 then alt_time
b12 = b11 - b1

if b12 = 0 then rittime

if b12 = 1 then onetogo

goto waits


onetogo:

'i2cslave %11010000, i2cslow, i2cbyte

hi2cin 0,(b0,b1)


gosub bcd_decimal
if b27 <> 0 then alt_time


if b0 > 45 then 
	wait 1
else
	if b0 > 30 then 
		wait 15
	else
		if b0 > 15 then
			wait 30
		end if
	end if
end if

'i2cslave %11010000, i2cslow, i2cbyte
if b11 >= 60 then
b11 = b11-60
end if
waitforcorrecttime:
hi2cin 0,(b0,b1)
gosub bcd_decimal
if b27 <> 0 then alt_time

if b1 = b11 then rittime
goto waitforcorrecttime


rittime:


gosub readings
if b23 = 0 then gosub readings


goto main




'##################################
'########## reset timing ##########
'##################################




resetlimitreached:


gosub readings
if b23 = 0 then gosub readings

for b1 = 1 to 13

wait 60
next b1


goto resetlimitreached




'##################################
'############### subs #############
'##################################





bcd_decimal:

b27 = 0

	let b7 = b0 & %11110000 / 16 * 10
	let b0 = b0 & %00001111 + b7
		if b0 > 60 then let b27 = 1 endif
	let b7 = b1 & %11110000 / 16 * 10
	let b1 = b1 & %00001111 + b7
		if b1 > 60 then let b27 = 1 endif
		
	let b7 = b2 & %11110000 / 16 * 10
	let b2 = b2 & %00001111 + b7
		if b2 > 60 then let b27 = 1 endif
	let b7 = b3 & %11110000 / 16 * 10
	let b3 = b3 & %00001111 + b7
		if b3 > 60 then let b27 = 1 endif

	let b7 = b4 & %11110000 / 16 * 10
	let b4 = b4 & %00001111 + b7
		if b4 > 60 then let b27 = 1 endif
	let b7 = b5 & %11110000 / 16 * 10
	let b5 = b5 & %00001111 + b7
		if b5 > 60 then let b27 = 1 endif
	
'	sertxd("\n 0: ",#b0," b1: ",#b1," b2: ",#b2," b3: ",#b3," b4: ",#b4," b5: ",#b5,"  failed?: ",#b27,CR,LF)
b27=0
	return
	


'##########################	
'########SLEEPS############
'##########################
	
	
	
tenleft:
'gosub freq_d
'sleep 200
for b1 = 1 to 8
wait 60
next b1
'gosub freq_u

'i2cslave %11010000, i2cslow, i2cbyte

hi2cin 1,(b1)
gosub bcd_decimal

	return




fiveleft:
'gosub freq_d
'sleep 100
'gosub freq_u
for b1 = 1 to 3
wait 60
next b1
wait 30
'i2cslave %11010000, i2cslow, i2cbyte

hi2cin 1,(b1)
gosub bcd_decimal

	return

twoleft:
'gosub freq_d
'sleep 50
'gosub freq_u

wait 60
wait 30
'i2cslave %11010000, i2cslow, i2cbyte

hi2cin 1,(b1)
gosub bcd_decimal

	return


oneleft:
'gosub freq_d
'sleep 20
'gosub freq_u

wait 40


'i2cslave %11010000, i2cslow, i2cbyte

hi2cin 1,(b1)
gosub bcd_decimal

	return



'#################################
'####inital next reading cal######
'#################################


calculatenext:

'i2cslave %11010000, i2cslow, i2cbyte

hi2cin 0,(b0,b1)

gosub bcd_decimal


'if b1 > 45 then
'	b1 = 60
'else
'	if b1 > 30 then
'		b1 = 45
'	else
'		if b1 > 15 then		
'			b1 = 30
'		else
'			b1 = 15		
'		endif
'	end if
'end if


b7 = b1/timep
b7 = b7 + 1
b11 = b7 * timep

if b11 > 60 then
b11 = b11 - 60
endif




'b11 has time of next reading (in mins)

sertxd("next reading",#b11,CR,LF)
return
	
	


freq_d:
'PEEK $1F,b0
'bit0 = 0
'POKE $1F,b0
'poke $8F,%000000000   ' set freq to 31khz
return


freq_u:
'setfreq m4
'PEEK $1F,b0
'bit0 = 1
'POKE $1F,b0
return












shiftin_MSB_init:
       
'w10 = 0
'shiftin_wait:
'pause 1
'w10 = w10 + 1
'if w10 = 20 then
'return
'endif
'if serdata = 0 then goto shiftin_wait

pause 5   ' wait for conv

if serdata = 1 then	' check the EOC bit, should be high to show data ready
pulsout sclk,1          ' clock one to get to first data bit
gosub shiftin_MSB_Pre   ' and bit bang the data
endif
return

shiftin_MSB_Pre:
let var_in = 0
for counter = 1 to bits 
var_in = var_in * 2
if serdata = 0 then skipMSBPre
var_in = var_in + 1
skipMSBPre:
pulsout sclk,1
next counter
return






'######################################
'######alt timing######################
'######################################


alt_time:

sertxd ("using alt time\n\n")

b27 = 0

for b27 = 1 to 13
wait 60
next b27
wait 40




gosub readings

if b23 = 0 then gosub readings

goto main




'######################################
'#################readings#############
'######################################


readings:
sertxd("start readings")
high 0

'i2cslave %11010000, i2cslow, i2cbyte
hi2cin 1,(b0,b1,b2,b3)
gosub bcd_decimal




readadc 0,b0
readadc 1,b1
readadc 2,b2
readadc 3,b27


w8 = timer
w3 = timer

b10 = b13
if input0 is on then
b10 = b10 + 20
endif


w3 = w3 * 2
if input0 is on then
if b13 = 1 then
else
w3 = w3 -1
endif
else
if b13 = 1 then
w3 = w3+1
else
endif
endif
if w3 = 65535 then
 w3 = 1
 endif


readtemp12 1,w2
readtemp12 5,w4

calibadc10 w9
w9 = 61400 / w9
w9= w9*100/105  ' correction
pause 10

count 2, 20000, b3
'ghg:
wait 1
high cs
for b27 = 0 to 150
pause 100
for b26 = 1 to 16
b0 = b26
pause 100
gosub setPGA

low cs2				'replace
pause 30
gosub shiftin_MSB_init
high cs2	
pause 10
sertxd(#b26,"  ",#w10,cr,lf)				'replace
if w10 > 255 then
	'b27 = b26
	goto moocat
endif
next b26
moocat:
if w10 <> 4095 then exit


pause 500
sertxd("try again ",#b27,cr,lf)
next b27
pause 10

w11 = w10


low cs
gosub shiftin_MSB_init
high cs

pause 10



readadc 0,b0
readadc 1,b1
readadc 2,b2
readadc 3,b27



wait 20
ptr = 0
hsersetup b2400_4, %01

serout 1,t2400,("C",CR)

wait 5

serout 1,t2400,("GET /weather/add.php?bc=1&pwd=weathercat2&l=",#b2,"&h=",#b0,"&b=",#w9,"&p=",#w10,"&ws=",#b3,"&wd=",#b27,"&t=",#w2,"&m=",#b1,"&r=",#w3,"&t2=",#w4,"&l2=",#w11,"&g=",#b26,"&b10=",#b10,"&w8=",#w8,"&b22=",#b22,"&b23=",#b23,"&b24=",#b24,"&b25=",#b25,"&b26=",#b26," HTTP/1.1",13,10,"HOST: www.hexoc.com",13,10,"USER-AGENT: XPORT",13,10,13,10)

pause 5
serout 1,t2400,($04)
         sertxd("GET /weather/add.php?bc=1&pwd=weathercat2&l=",#b2,"&h=",#b0,"&b=",#w9,"&p=",#w10,"&ws=",#b3,"&wd=",#b27,"&t=",#w2,"&m=",#b1,"&r=",#w3,"&t2=",#w4,"&l2=",#w11,"&g=",#b26,"&b10=",#b10,"&w8=",#w8,"&b22=",#b22,"&b23=",#b23,"&b24=",#b24,"&b25=",#b25,"&b26=",#b26," HTTP/1.1",13,10,"HOST: www.hexoc.com",13,10,"USER-AGENT: XPORT",CR,LF)
sertxd("FINISH",CR,LF,CR,LF)


wait 5

low 0
w10 = hserptr
hsersetup OFF
ptr = 0
b23 = 0

for w9 = 0 to w10

sertxd(@ptr)

if @ptrinc = "Z" then
	b22 = ptr

	if @ptrinc <> "o" then false_alarm
	if @ptrinc <> "n" then false_alarm
	if @ptrinc <> "e" then false_alarm
	if @ptrinc <> ":" then false_alarm
	if @ptrinc <> " " then false_alarm
	if @ptrinc <> "D" then false_alarm
	b23 = 1
	sertxd("\n\nsuccess\n\n")

	false_alarm:
	ptr = b22
end if

next w9
sertxd("\n\n")
b23 = 1     'remove
if b23 = 1 then
	timer = 0
	settimer count 65535
	timer = 0
	b13 = 0
	if input0 is on then 
		b13 = 1 
	endif
endif


'wait 60
gosub calculatenext

sertxd ("finished readings\n\n")
return









setPGA:

low pgaCS
pause 60
for counter = 1 to 8


	if bit7 = 1 then
		high adout
	else
		low adout
	endif

	pulsout sclk, 100
	b0 = b0*2


next counter

high pgaCS

return



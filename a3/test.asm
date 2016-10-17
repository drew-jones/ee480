_addv_negv:
li $u2,8
li $u3,8
morei $u2,7
morei $u3,7
negv $u3,$u3
addv $u4,$u2,$u3
li $u9,16
jz $u4,$u9
sys

_or:
li $u2, 67
li $u3, 0
and $u4, $u2,$u3
li $u5, -1
nop
and $u6,$u2,$u5
neg $u2,$u2
add $u7,$u2,$u6
li $u9,32
jz $u4,$u9
sys
li $u9,48
jz $u7,$u9
sys

_any_anyv:
li $u2,8
morei $u2,9
morei $u2,10
morei $u2,11
anyv $u2,$u2
li $u3,-1
nop
addv $u4,$u2,$u3
li $u9,64
jz $u4,$u9
sys
li $u2,11
li $u3,-1
any $u2,$u2
add $u4,$u3,$u2
li $u9,80
jz $u4,$u9
sys
li $u2,0
nop
any $u2,$u2
li $u9,96
jz $u2,$u9
sys

_load_store_jnz:
li $u2,8
li $u3,3
st $u2,$u3
ld $u4,$u3
li $u9,112
jnz $u4,$u9
sys

_xor:
li $u2,2
li $u3,2
xor $u4,$u2,$u3
li $u9,1
morei $u9,0
jz $u4,$u9
sys
xor $u5,$u4,$u2
li $u3,-2
nop
add $u6,$u5,$u3
li $u9,1
morei $u9,16
jz $u6,$u9
sys

_shift:
li $u2,4
li $u3,2
shift $u4,$u2,$u3
neg $u3,$u3
shift $u5,$u2,$u3
li $u6,-16
li $u7,-1
add $u6,$u4,$u6
add $u7,$u5,$u7
li $u9,1
morei $u9,32
jz $u6,$u9
sys
li $u9,1
morei $u9,48
jz $u7,$u9
sys

_pack_unpack:
li $u2,20
morei $u2,1
li $u3,-1
nop
pack $u4[0001],$u2
nop
add $u5,$u4,$u3
li $u9,1
morei $u9,64
jz $u5,$u9
sys
li $u2,20
morei $u2,13
morei $u2,8
morei $u2,5
li $u3,-33
nop
unpack $u4,$u2[11]
nop
add $u5,$u4,$u3
li $u9,1
morei $u9,80
jz $u5,$u9
sys

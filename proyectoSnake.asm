.model small 
.386 
 
 	 	Tiempo      equ 1          ;numero de 55 Milisegundos entre los movimientos 
 	 	LineaInicio equ 1           ;primera linea del borde (de 0 a 24) 
 	 	LineaFin    equ 24          ;ultima linea del borde 
 	 	ColInicio   equ 0           ;primera columna del borde ( de 0 a 79) 
 	 	ColFin      	equ 60          ;ultima columna del borde esquinas 	 
     	Altura  equ LineaFin-LineaInicio-1   ;número de filas de altura excepto las las esquinas 	 
     	Largo    equ ColFin-ColInicio-1     ;número de columnas de ancho excluyendo 
 	 	XPunt       equ 6*160+60    ;Columna de la puntuación 
 	 	XInicio     equ 59          ;Columna inicial de la serpiente 
 	 	YInicio     equ 12          ;Línea de salida de la serpiente 
 	 	CharSerp    equ 'Û' 
 	 	CharOgg     equ 02h         ;Carácter de los números que se deben tomar 
 	 	ColPunt     equ 0Ah         ;Color de puntuación 
 	 	ColBorde    equ 0Fh         ;color del borde 
 	 	ColFondo    	equ 01h         ;color de fondo 
 	 	ColSerp     equ 0Ah         ;color de la serpierte 
 	 	ColChar     equ 0Eh         ;color del caracter 
 
 	 	MsgPersoLen equ MsgPersoEnd-MsgPerso    ;longitud del mensaje 
 	 	MsgPuntLen  equ MsgPuntEnd-MsgPunt  

.stack 200h .data? 
 	 	Cola        dw 100 dup(?)   ;cola de la serpiente 
 	 	ColaStop    LABEL           ;bytes en cola 
 
 	 	InicioCola  dw ?            ;dirección de inicio de la cola 
 	 	FinCola     	dw ?             	;direccion de Fin Cola 
 	 	Flag        dw ?            ;flag para Tiempo 
 	 	NumPos      dw ?            ;coordinate del numero 
 	 	Crecer      	db ?            ;1 = debe alargarse , 0 = no debe alargarse 
 	 	ModoVideo   db ?            ;Modo de vídeo antes de la salida 

.data 
 	 	IncY        db 0            ;Incremento de la linea 
 	 	IncX        db 0            ;Incremento de columna 
 
 	 	Numero      db 1            ; 
 	 	Puntaje    	dw 0              	;puntuación 
 	 	Perdio  	db ' Perdiste :(',10,10,13 
 	 	MsgPunt     db '  PUNTOS :  0' 
 	 	MsgPuntEnd  LABEL 
 
 	 	Presenta 	db 10,10,10,10,13,' SNAKE v1.0.0',10,10,13 
 	 	 	 	 	db ' INGENIERIA DE SISTEMAS  UNA-PUNO',10,10,13 
 	 	 	 
BAJO NIVEL',10,10,13 	 	db ' CURSO: COMPUTACION Y PROGRAMACION DE 
 	 	 	 	 	db ' PRESENTADO POR:',10,10,13 
          MsgPerso    db '       MAMANI MOYA, ROBERTH ',10,10,13,10,10  	 	 	 	 	
          db ' Presione una tecla para continuar...',10,10,13,'$' 
 	 	MsgPersoEnd LABEL 


.code start: 
 	 	mov ax,@data  	 	mov ds,ax  	 	mov ax,0B800h  	 	mov es,ax 
 
 	 	mov ah,0Fh  	 	int 10h 
 	 	mov ModoVideo,al 
	 	mov ax,3                ;establece el modo video a 80x25 
	 	int 10h 
 	lea dx,Presenta         ;muestra la presentacion mov ah,9 int 21h 
mov ah,7                ;espera pulsa una tecla int 21h 
mov ax,3                ;borra la pantalla int 10h 
 
 	 	mov ah,2                ;oculta el cursor 
 	 	mov bl,0  	 	mov dx,2500h  	 	int 10h 
 
 
 	 	mov al,ColSerp + 16*ColFondo       ;Color  	 	mov di,1                ;primer atributo de la primera página  	 	mov cx,2000             ;numero total de casillas 
 
PreparaFondo: 
 	 	mov es:[di],al  	 	add di,2  	 	dec cx 
 	 	jnz PreparaFondo 
 
 	 	mov ah,ColBorde+16*ColFondo    ;color del Borde 
 
 	 	mov al,'É' 
  mov di,(160*LineaInicio)+(2*ColInicio)   mov es:[di],ax 
 
 	 	mov al,'Í'  	 	add di,2 
 	 	mov cx,Largo              ;Borde superior BordeSup: 
 	 	mov es:[di],ax  	 	add di,2  	dec cx  	jnz BordeSup 
mov al,'»' 
	 	mov es:[di],ax 
mov al,'È' 
mov di,(160*LineaFin)+(2*ColInicio) mov es:[di],ax add di,2       
mov al,'Í' mov cx,Largo            ;Borde inferior 
BordeInf: 	
 	 	mov es:[di],ax 
 	 	add di,2 
 	 	dec cx 
 	 
 	jnz BordeInf 
 	 	mov al,'¼' 
 	 
 	mov es:[di],ax 
 	 
 	mov bx,160              ;longitud en bytes de una línea 
 	 	mov al,'º' 
 	 	mov di,160*(LineaInicio+1)+(2*ColInicio)    ;inicio del borde izquierdo 
 	 
BordeIzq: 	mov cx,Altura 
 	 	mov es:[di],ax 
 	 	add di,bx 
 	 	dec cx 
 	 	jnz BordeIzq 
 	 	mov di,160*(LineaInicio+1)+(2*ColFin)       ; bx = 160 
 	 
BordeDer: 	mov cx,Altura 
 	 	mov es:[di],ax 
 	 	add di,bx 
 	 	dec cx 
 	 
 	jnz BordeDer 
 	 
 	call MuestraPuntaje            ;Muestra el Puntaje 
 	 	  
 	mov ah,XInicio mov al,YInicio mov Cola,ax                     ;establece el punto de partida de la serpiente 
mov InicioCola,offset Cola mov FinCola,offset Cola call ConvertAddr mov di,ax 
;llama la cabeza de la serpiente mov word ptr es:[di],256*(16*ColFondo+ColSerp)+CharSerp 
 
 	 	mov ah,0                ;inicia el ciclo 
 	 	int 1Ah  	 	mov Flag,dx 
 
 	 	call Crea_numero  	 	mov Crecer,0 
 
ciclo: 
 
 	 	mov ah,0  	 	int 1ah  	 	mov ax,dx  	 	sub ax,Flag 
 	 	cwd 
 	 	xor ax,dx 
 	 	adc ax,0                 
 	 	cmp ax,Tiempo 
 	 	ja Mover_cursor         
 
 	 	mov ah,1  	 	int 16h 
 	 	jnz ControlaTecla      ;pulsa caracter 
 
 	 	jmp ciclo 
 
Mover_cursor:              ;mueve la serpierte 
 	 	mov ah,0  	 	int 1ah 
mov Flag,dx                 ;verifica el Tiempo 
mov si,FinCola cmp Crecer,0 
 	jne Inicio_Cola             ;salta si crece mov ax,[si] 
call ConvertAddr mov di,ax mov ax,256*(ColSerp+16*ColFondo)+' ' 
mov es:[di],ax                       add si,2 cmp si,offset ColaStop              ;sobre la cola 
 	 	jne Inicio_Cola  	 	mov si,offset Cola 
Inicio_Cola: 
 	 	mov FinCola,si  	 	mov Crecer,0 
 
 	 	mov si,InicioCola                   ;cabeza de la serpiente 
 	 	mov ax,[si]  	 	add ah,IncX  	 	add al,IncY  	 	push ax 
 	 	call ConvertAddr  	 	mov di,ax 
 	 	mov word ptr es:[di],256*(ColFondo*16+ColSerp)+CharSerp 
 	 	add si,2 
 	 	cmp si,offset ColaStop  	 	jne Fin_mover  	 	mov si,offset Cola 
 
Fin_mover:                         ;Fin del los movimientos 
 	 	mov InicioCola,si 
 	 	pop ax 
 	 	mov [si],ax                         ;gurda las coordenadas de la cabeza  	 	call ControlarChoque                     ;controlar si se tropa con algo 
 
 	 	jmp ciclo 
 
ControlaTecla:            ;compruebe que ha pulsado el tecla Š  	 	mov ax,offset CtrTecla_Fin 
push ax 
	 	mov ah,0 
int 16h                     ;remueve el caracter del buffer cmp ax,4800H                ;flecha hacia arriba 
	 	je Flecha_Arriba 
cmp ax,4B00H                ;flecha hacia izquierda je Flecha_Izq 
cmp ax,4D00H                ;flecha hacia la derecha je Flecha_Der cmp ax,5000H                ;flecha hacia abajo je Flecha_Abajo cmp ax,3B00H                ; tecla F1 para terminar o salir del juego je Fin CtrTecla_Fin: 
 	 	jmp ciclo 
 
 
Flecha_Arriba: 
 	 	cmp IncY,1 
 	 	je FlechaArriba_OK 
 	 	mov word ptr [IncY],00FFh           ;IncX = 0, IncY = -1 
FlechaArriba_OK:                       ;inversione di direzione 
 	 	retn 
 
Flecha_Izq: 
 	 	cmp IncX,1  	 	je FlechaDer_OK 
  mov word ptr [IncY],0FF00H          ;IncX = -1, IncY = 0 FlechaDer_OK: 
 	 	retn 
 
Flecha_Der: 
 	 	cmp IncX,-1  	 	je FlechaIzq_OK 
  mov word ptr [IncY],0100h           ;IncX = 1, IncY = 0     FlechaIzq_OK: 
 	 	retn 
 
Flecha_Abajo: 
 	 	cmp IncY,-1  	 	je FlechaAbajo_OK 
 	 	mov word ptr [IncY],0001h           ;IncX = 0, IncY = 1 FlechaAbajo_OK: 
 	 	retn 
 
ControlarChoque:              ;controla si golpea el muro o un numero  	cmp al,LineaInicio           ;Borde superior  	jz Choque 
cmp al,LineaFin             ;Borde inferior 
je Choque cmp ah,ColInicio            ;Borde izquierdo jz Choque cmp ah,ColFin              ;Borde derecho je Choque 
 	 	call ChoqueCola               ;verifica si se golpeo la cola  	 	jc Choque                   ;saltar si la colisión se produjo Š 
 
 	 	cmp ax,NumPos               ;verifica si se golpeo un numero 
 	 	jne Fin_ConChoque  	 	call Crea_numero 
 
 	 	add Puntaje,10            ;incrementa el Puntaje  	 	call ConvPuntaje          ;convierte en una cadena  	 	call MuestraPuntaje        ;muestra el Puntaje 
 
Fin_ConChoque: 
 	 	ret 
 
Choque:                  	 	;si se produjo un choque o golpe 
 	 	; mov ax,2009h            ;muestra el mensaje 
 	 	; call ConvertAddr 
 	 	; mov di,ax 
 	 	; mov cx,MsgPersoLen 
 	 	; lea si,MsgPerso 
; Choque_msg: 
 	 	; mov al,[si] 
 	 	; mov es:[di],al 
 	 	; inc si 
 	 	; add di,2 
 	 	; dec cx 
 	 	; jnz Choque_msg 
 
 
 	 	mov ah,7  	 	int 21h 
 
 	 	jmp Fin 
 
Crea_numero: 
mov ah,0 
int 1ah xor ax,ax mov al,dl mov dl,Altura 
div dl                   
	 	mov bl,ah 
 	 	add bl,LineaInicio+1  	 	mov ah,0                 
 	 	int 1ah  	 	xor ax,ax  	 	mov al,dl  	 	mov dl,Largo  	 	div dl  	 	mov bh,ah 
 	 	add bh,ColInicio+1  	 	mov ax,bx  	 	mov [NumPos],ax  	 	push ax  	 	cmp Numero,2  	 	jbe CreaNumero_OK 
 	 	call ChoqueCola           ;controla si se golpeo la Cola  	 	jc Crea_numero          ;si se encuentra en otra posicion CreaNumero_OK: 
 
 	 	pop ax                  ;ax = posicion del numero 
 	 	call ConvertAddr  	 	mov di,ax 
 	 	mov ah,16*ColFondo+ColChar  	 	mov al,CharOgg 
 	 	mov es:[di],ax          ;visualiza el numero  	 	inc Numero 
 	 	mov Crecer,1           ;dice a la cola crecer 
 	 	ret 
 
Fin: 
 	 	mov al,ModoVideo      ;establece el modo de vídeo a la anterior  	 	mov ah,0  	 	int 10h 
 
 	 	lea dx,Perdio         ;muestra msg perdiste  	 	mov ah,9 
int 21h 
S1: 		
 		mov ah,0              ;espera la pulsacion de una tecla 
 		int 16h 
 		 
 		cmp ax,3B00H          ; tecla F1 para terminar o salir del juego 
 	 	je Salir 
 
Salir: 	 	jmp S1 
 	 	mov ax,4c00h 
 	 	int 21h 
 	 	 
;*************************************************************************** 
ConvertAddr proc near 
;convierte la X e Y pasado en la dirección de AH y AL en memoria de vídeo ;requiere: 
;           AH = X 
;           AL = Y 
; 
;retorna: 
;           AX = offset 
 	 	push bx  	 	push cx 
 
 	 	mov bx,ax  	 	xor ah,ah 
 	 	shl ax,5            ;AL * 32 
 	 	mov cx,ax 
 	 	shl ax,2            ;AL * 4  	 	add ax,cx           ;AL * 5 = AL * 160  	 	shl bh,1            ;X * 2  	 	add al,bh 
 	 	adc ah,0            ;ADDR = 2*X + 160*Y 
 
 	 	pop cx  	 	pop bx  	 	retn 
ConvertAddr endp 
 
;*************************************************************************** 
ChoqueCola proc 
;controla si se algo afecto ala cola ;requiere: 
;           AH = X 
;           AL = Y 
;retorna: 
;           CF = 1 si se produjo la colision 
;           CF = 0 si no se produjo la colision 
 
 	 	cmp Numero,2  	 	je ChoqueCola_Fin  	 	mov di,[InicioCola]  	 	mov si,[FinCola]  	 	cmp si,di  	 	ja ChoqueCola_inv 
 
 	 	sub di,si               ;Longitud de la Cola en bytes 
 	 	mov cx,di 
 	 	shr cx,1                ;longitud en word                  	 	call ChoqueCiclo          ;verifica el choque o impacto  	 	jmp ChoqueCola_Fin       ;esce 
 
ChoqueCola_inv:  	 	mov si,offset Cola      ;inicio de la cola  	 	sub di,si                
 	 	jz ChoqueCola_inv2  	 	mov cx,di 
 	 	shr cx,1                ;convierte en word 
 	 	call ChoqueCiclo 
 	 	jc ChoqueCola_Fin        ;salta si se produjo la colision  ChoqueCola_inv2:          ;controla la parte final 
 	 	mov si,[FinCola]  	 	mov cx,offset ColaStop  	 	sub cx,si 
 	 	shr cx,1                ;la longitud de la segunda parte 
 	 	call ChoqueCiclo 
 
ChoqueCola_Fin:          ;Fin del procedimiento  	 	ret 
ChoqueCola endp 
 
;*************************************************************************** ChoqueCiclo proc 
; 
;Requiere: 
;               DS:SI = dirección de inicio de la búsqueda 
;               CX = numero en word a controlarse ;               AX = word de cercare ;Restituisce : 
;               CF = 1 sis se produjo el choque 
;               CF = 0 si no se produjo el choque 
 
ChoqueCiclo_ciclo: 
 	 	cmp [si],ax  	 	je ChoqueCiclo_urtato 
 	 	add si,2  	 	dec cx 
 	 	jnz ChoqueCiclo_ciclo 
 	 	clc  
 	 	jmp ChoqueCiclo_Fin 
 
ChoqueCiclo_urtato:       ;char Š se produjo el choque 
 	 	stc 
 
ChoqueCiclo_Fin:  	 	ret 
ChoqueCiclo endp 
 
;*************************************************************************** 
ConvPuntaje proc 
;Convierte el puntaje en String o cadena 
 
 	 	pusha                     	 	mov cl,30h              	 	mov bx,10                 	 	mov ax,Puntaje 
 	 	lea di,MsgPuntEnd-1     ;Apunta al final de la cadena ConvP_ciclo: 
 	 	xor dx,dx 
 	 	div bx                   
 	 	add dl,cl               ;convierte el resto en ASCCI  	 	mov [di],dl             ;copia la cifra  	 	dec di                  ;decrementa puntero de la cadena  	 	or ax,ax                 
 	 	jnz ConvP_ciclo 
 
 	 	popa  
 
 	 	ret 
ConvPuntaje endp 
 
;*************************************************************************** 
MuestraPuntaje proc 
;Muestra el Puntaje 
 
 	 	push si  	 	push di  	 	push ax  	 	push cx 
 
 	 	lea si,MsgPunt          ;offset de la cadena MsgPunt  	 	mov di,2*XPunt          ;Direccion del Puntaje  	 	mov cx,MsgPuntLen       ;Longitud de la de la cadena Puntos  	 	mov ah,ColPunt+(16*ColFondo)       ;Color del Puntaje MuestraP_ciclo: 
 	 	mov al,[si]  	 	mov es:[di],ax  	 	inc di  	 	inc si  	 	inc di  	 	dec cx 
 	 	jnz MuestraP_ciclo 
 
 	 	pop cx  	 	pop ax  	 	pop di  	 	pop si  	 	ret 
MuestraPuntaje endp 
;***************************************************************************
 end start 

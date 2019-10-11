.model small 
.data 
    bienvenida db 'PROYECTO MICROPROGRAMACION: Snake $'
    instrucciones db 'USE LAS TECLAS: A, S, D W $'
    dimensiones db 'LAS DIMENSIONES INGRESADAS SON INCORRECTAS. $'
    cerrar db 'HA CERRADO EL JUEGO.$'
    salida db 'PERDISTE$'
    cadena1 db  "Ingrese X: $";ingrese coordenada x
    cadena2 db  "Ingrese Y: $";ingrese coordenada y
    pared db 219
    cabeza db '>'  
    cuerpo db 'O'   
    checkx db ? 
    checky db ? 
    posx db ? 
    posy db ? 
    u db ? ; unidades por si ingresa numero de dos digitos 
    d db ? ; decenas por si ingresa numero de dos digitos     
    x db ? ; pared horizontal del juego 
    y db ? ; pared vertical del juego 
    i db 1h ; para recorrer horizontalmente la pantalla con el cursor
    j db 1h ; para recorrer verticalmente la pantalla con el cursor
    dos db 2    
    negar db -1 
.stack 
    ;dw   128  dup(0) 
.code 
programa: 
    mov ax, @data
    mov ds, ax  

    mov ax, ax  ;limpiar registros 
    
    ;solicitar del teclado x
    mov ah, 09
    lea dx, cadena1
    int 21h
    mov ah, 01
    int 21h
    sub al, 30h
    mov d, al 
    
    mov ah, 01
    int 21h
    sub al, 30h
    mov u, al 

    mov al, d 
    mov bl, 10 
    mul bl 
    add al, u
    mov checkx, al 

    mul dos ;  duplicar el tamaño 
    mov x, al
    
    call SALTOLINEA

    ;solicitar del teclado y
    mov ah, 09
    lea dx, cadena2
    int 21h
    mov ah, 01
    int 21h
    sub al, 30h
    mov d, al 
    
    mov ah, 01
    int 21h
    sub al, 30h
    mov u, al 

    mov al, d 
    mov bl, 10 
    mul bl 
    add al, u
    mov checky, al 

    mul dos ; duplicar el tamaño 
    mov y, al

    call SALTOLINEA  

    cmp checkx, 4 
    jz Paso 

    ;MOSTRAR EL TABLERO DE JUEGO     
    mov ax, 0003H ;clearing the screen 
    int 10H     
    
    mov cl, x ;mostrar primera fila 
    call FILA 
    xor cl, cl    
    xor dx, dx ; limpinado registros 

    ;mostrar segunda fila     
    mov cl, x
    mov bl, y 
    mov i, bl 
    mov j, 1h 
    call FILA 
    xor cl, cl 
    xor dx, dx 
    
    ;mostrar primera columna 
    mov cl, y 
    mov j, 1h 
    mov i, 1h 
    call COLUMNA    
    xor cl, cl 
    xor dx, dx 
    
    ;mostrar segunda columna 
    mov cl, y
    mov bl, x  
    mov j, bl 
    mov i, 1h 
    call COLUMNA
    
    ;empieza el juego    
    ;posicionar al centro a la serpiente 
    mov al, checkx 
    mov posx, al 
    mov bl, checky
    mov posy, bl 
    
    mov ah, 02h     
    mov dh, posx 
    mov dl, posy 
    int 10h 

    mov ah, 02h 
    mov dl, cabeza 
    int 21h 
    ;CICLO PRINCIPAL 
ciclo:     
    call LeerKbd

    jmp ciclo     

Paso: 
    jmp DimensionesIncorrectas

FILA:     
    mov ah, 02h         
    mov dh, i 
    mov dl, j     
    int 10h ; interrupcion para colocar el cursor 
    mov dl, pared ; imprimir caracter de la pared
    mov ah, 02h 
    int 21h     
    inc j
    loop FILA
    ret 

COLUMNA: 
    mov ah, 02h         
    mov dh, i 
    mov dl, j     
    int 10h ; interrupcion para colocar el cursor 
    mov dl, pared ; imprimir caracter de la pared 
    mov ah, 02h 
    int 21h     
    inc i
    loop COLUMNA  
    ret 

LeerKbd proc ;LEER ENTRADA DEL TECLADO PARA MOVIMIENTO DE LA SERPIENTE 
    mov ah, 00h
    int 16h

    cmp al, 'w'
    jne izquierda    
    cmp cabeza, 'v'
    je retrocedio
    mov cabeza, '^'
    call moverArriba
    call validarArr 
    ret
izquierda: 
    cmp al, 'a'
    jne derecha
    cmp cabeza, '>'
    je retrocedio 
    mov cabeza, '<'
    call moverIzquierda
    call validarIzq 
    ret
derecha: 
    cmp al, 'd'
    jne abajo 
    cmp cabeza, '<'
    je retrocedio 
    mov cabeza, '>' 
    call moverDerecha   
    call validarDer
    ret 
abajo:
    cmp al, 's'
    jne retrocedio 
    cmp cabeza, '^'
    je retrocedio 
    mov cabeza, 'v'
    call moverAbajo
    call validarAb 
    ret         
retrocedio:  
    cmp al, 'x' 
    je salir
    ret 
salir: 
    mov ax, 0003H ;clearing the screen 
    int 10H    
    lea dx, cerrar 
    mov ah, 09h 
    int 21h ; mostrar mensaje
    mov ah, 4CH; terminar juego  
    int 21H
    ret
LeerKbd endp 

Mover proc 
moverArriba:
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde irá caracter 
    mov ah, 02h 
    mov dl, 32
    int 21h ; escribir espacio en donde estaba el carcter 
    sub posy, 1h ; subir la serpiente   
    ; comparar con checky para ver si está en el borde         
    mov ah, 02h 
    mov dh, posy
    mov dl, posx
    int 10h ; poner cursor donde irá caracter 
    mov dl, cabeza
    mov ah, 02h 
    int 21h 
    ret 
moverAbajo: 
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde irá caracter 
    mov ah, 02h 
    mov dl, 32
    int 21h ; escribir espacio donde estaba el caracter 
    sub posy, -1h ; subir la serpiente           
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde irá caracter 
    mov dl, cabeza
    mov ah, 02h 
    int 21h 
    ret
moverDerecha: 
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde irá caracter 
    mov ah, 02h 
    mov dl, 32
    int 21h ; escribir espacio donde estaba el caracter 
    sub posx, -1h ; subir la serpiente           
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde irá caracter           
    mov dl, cabeza
    mov ah, 02h 
    int 21h          
    ret
moverIzquierda: 
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde irá caracter 
    mov ah, 02h 
    mov dl, 32
    int 21h ; escribir espacio donde estaba el caracter 
    sub posx, 1h ; subir la serpiente           
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde irá caracter 
    mov dl, cabeza
    mov ah, 02h 
    int 21h 
    ret    
Mover endp     

validacion proc 
validarArr:     
    cmp posy, 1
    je terminaJuego 
    ret 
validarAb: 
    mov bl, y 
    cmp posy, bl
    je terminaJuego
    ret
validarIzq: 
    cmp posx, 1 
    je terminaJuego 
    ret 
validarDer: 
    mov bl, x 
    cmp posx, bl 
    je terminaJuego 
    ret
validacion endp

terminaJuego: 
    mov ax, 0003H ;clearing the screen 
    int 10H     
    mov ah, 09h 
    lea dx, salida
    int 21h 
    jmp FIN 
    
SALTOLINEA:
    ; imprimir un salto de linea antes de mostrar un resultado
    MOV DL, 10
    MOV AH, 02
    INT 21h
    MOV DL, 13
    INT 21H
    XOR AX, AX 
    ret   
    
DimensionesIncorrectas:
    lea dx, dimensiones
    mov ah, 09h 
    int 21h 
    jmp FIN 

FIN: 
    MOV AH, 4CH 
    INT 21H

end programa
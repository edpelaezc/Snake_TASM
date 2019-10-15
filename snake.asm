.model small 
.data 
    bienvenida db 'PROYECTO MICROPROGRAMACION: Snake $'
    instrucciones db 'USE LAS TECLAS: A, S, D W $'
    dimensiones db 'LAS DIMENSIONES INGRESADAS SON INCORRECTAS. $'
    msg db 'MOVIMIENTO INVALIDO$'
    clean db '                   $'
    msgx db 1h 
    msgy db 0h 
    cerrar db 'HA CERRADO EL JUEGO.$'
    salida db 'PERDISTE$'
    cadena1 db  "Ingrese X: $";ingrese coordenada x
    cadena2 db  "Ingrese Y: $";ingrese coordenada y
    pared db 219
    cabeza db '>'  
    cuerpo db 'O'   
    manzana db 207  
    contManzana db 4
    right db ?     
    bottom  db ?     
    checkx db ? 
    checky db ? 
    long db 4
    posx db ? 
    posy db ? 
    xa db ? 
    ya db ? 
    xBorrar db ? 
    yBorrar db ? 
    u db ? ; unidades por si ingresa numero de dos digitos 
    d db ? ; decenas por si ingresa numero de dos digitos     
    x db ? ; pared horizontal del juego 
    y db ? ; pared vertical del juego 
    i db 1h ; para recorrer horizontalmente la pantalla con el cursor
    j db 1h ; para recorrer verticalmente la pantalla con el cursor
    dos db 2    
    negar db -1 
    xcola db ?
    ycola db ?
    cBorrarX db ?
    cBorrarY db ?
.stack 
    dw   128  dup(0) 
.code 
programa: 
    mov ax, @data
    mov ds, ax  
    mov ax, ax  ;limpiar registros 
    
    mov ah, 09 
    lea dx, [instrucciones]
    int 21h 
    call SALTOLINEA
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

    mul dos ;  duplicar el tama?o 
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

    mul dos ; duplicar el tama?o 
    mov y, al

    call SALTOLINEA  

    cmp checkx, 4 
    je Paso 
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
    mov posy, bl ; poner al centro la cabeza
    mov ah, 02h     
    mov dh, posx 
    mov dl, posy 
    int 10h ; posicionar cursor 
    mov ah, 02h 
    mov dl, cabeza 
    int 21h ; imprimir cabeza
    call imprimir_cuerpo 
    call imprimirManzanas
    jmp ciclo
Paso proc 
    jmp dim 
    ret
Paso endp      
    ;CICLO PRINCIPAL ---------------------------------------------------------------------------------------------------
ciclo:     
    call LeerKbd       
    jmp ciclo  
    ;CICLO PRINCIPAL ---------------------------------------------------------------------------------------------------
imprimir_cuerpo:
    ;Imprimir el cuerpo inicial de la serpiente que sean 4 unidades a la izquierda
    ;Obtengo las posiciones para imprimir el cuerpo de la serpiente
    mov dh, posx
    mov dl, posy
    mov xa, dh
    mov ya, dl
    mov cl, long
    ciclo_imprimir_cuerpo:
        sub xa, 01h
        mov dl, xa
        mov dh, ya
        mov al, xa ;guardo posicion de X del nuevo fragmento de cuerpo
        mov xcola, al
        mov al, ya ;guardo posicion de Y del nuevo fragmento de cuerpo
        mov ycola, al; cuando termine el ciclo tendran la posicion del ultimo fragmento
        int 10h
        mov dl, cuerpo
        mov ah, 02h 
        int 21h
        mov dl, xa
        mov dh, ya
        int 10h
        loop ciclo_imprimir_cuerpo
        ret   
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
imprimirManzanas proc 
    mov bl, [x]    
    mov [right], bl 
    sub right, 4
    mov bl, [y]    
    mov [bottom], bl 
    sub bottom, 4
    mov ah, 02h 
    mov dh, 4
    mov dl, 4
    int 10h ; cursor 
    mov dl, [manzana]
    int 21h ; primera manzana 
    mov dh, 4
    mov dl, right ; cursor 
    int 10h 
    mov dl, [manzana] ; segunda manzana 
    int 21h 
    mov dh, bottom 
    mov dl, right ; cursor 
    int 10h 
    mov dl, [manzana] ; tercera manzana 
    int 21h 
    mov dh, bottom 
    mov dl, 4 ; cursor 
    int 10h 
    mov dl, [manzana] ; tercera manzana 
    int 21h 
    ret
imprimirManzanas endp 

LeerKbd proc ;LEER ENTRADA DEL TECLADO PARA MOVIMIENTO DE LA SERPIENTE     
    mov ah, 00h
    int 16h; lee sin imprimir el caracter ingresado 
    cmp al, 'w'
    jne izquierda    
    cmp cabeza, 'v'
    je checkRetro
    mov cabeza, '^'     
    call moverArriba
    call validarArr   
    call comp1                
    call comp3
    call comp5
    call comp7
    call limpiar
    ret
izquierda:     
    cmp al, 'a'
    jne derecha
    cmp cabeza, '>'
    je retrocedio 
    mov cabeza, '<'
    call moverIzquierda
    call validarIzq   
    call comp1    
    call comp3    
    call comp5
    call comp7
    call limpiar
    ret
checkRetro: 
    jmp retrocedio 
derecha:     
    cmp al, 'd'
    jne abajo 
    cmp cabeza, '<'
    je retrocedio 
    mov cabeza, '>' 
    call moverDerecha   
    call validarDer   
    call comp1  
    call comp3 
    call comp5
    call comp7 
    call limpiar
    ret 
abajo:    
    cmp al, 's'
    jne retrocedio 
    cmp cabeza, '^'
    je retrocedio 
    mov cabeza, 'v'
    call moverAbajo
    call validarAb 
    call comp1  
    call comp3  
    call comp5
    call comp7   
    call limpiar
    ret         
retrocedio:  
    cmp al, 'X' 
    je salir
    mov ah, 02h 
    mov dh, [msgy]
    mov dl, [msgx]
    int 10h ; posicionar cursor 
    mov ah, 09
    lea dx, [msg]
    int 21h 
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
    int 10h ; poner cursor donde ir? caracter     
    mov dl, 32 
    int 21h 
    sub posy, 1h ; subir la serpiente       
    mov ah, 02h 
    mov dh, posy
    mov dl, posx
    int 10h ; poner cursor donde ir? caracter 
    mov dl, cabeza
    mov ah, 02h 
    int 21h    
    call colaArr   
    mov ah, 02h
    mov dh, posy
    mov dl, posx
    add dh, 1h
    int 10h
    mov ah, 02h
    mov dl, cuerpo
    int 21h      
    ret 
moverAbajo: 
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde ir? caracter 
    mov dl, 32 
    int 21h 
    sub posy, -1h ; subir la serpiente           
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde ir? caracter 
    mov dl, cabeza
    mov ah, 02h 
    int 21h     
    call colaAb 
    mov ah, 02h
    mov dh, posy
    mov dl, posx
    add dh, -1h
    int 10h
    mov ah, 02h
    mov dl, cuerpo
    int 21h
    ret
moverDerecha: 
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde ir? caracter 
    mov dl, 32 
    int 21h 
    sub posx, -1h ; subir la serpiente           
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde ir? caracter           
    mov dl, cabeza
    mov ah, 02h 
    int 21h
    call colaDer;Despues de borrar la vieja cola tengo que agregar el nuevo cuello
    mov ah, 02h
    mov dh, posy
    mov dl, posx
    add dl, -1h
    int 10h
    mov ah, 02h
    mov dl, cuerpo
    int 21h
    ret
moverIzquierda: 
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde ir? caracter 
    mov dl, 32
    int 21h 
    sub posx, 1h ; subir la serpiente           
    mov ah, 02h 
    mov dh, posy
    mov dl, posx 
    int 10h ; poner cursor donde ir? caracter 
    mov dl, cabeza
    mov ah, 02h 
    int 21h 
    call colaIzq
    mov ah, 02h
    mov dh, posy
    mov dl, posx
    add dl, 1h
    int 10h
    mov ah, 02h
    mov dl, cuerpo
    int 21h
    ret    
Mover endp    

validacion proc 
validarArr:    
    cmp posy, 1
    je terminaJuego ; valida el choque contra la pared 
    mov ah, 02h 
    mov dl, posx 
    mov dh, posy     
    dec dh
    int 10h ; poner cursor en la cabeza 
    mov ah, 08h ; interrupcion 10h para leer contenido del cursor 
    int 10h 
    cmp al, [cuerpo] ; la serpiente choca contra su cuerpo 
    je terminaJuego  
    ret 
validarAb: 
    mov bl, y 
    cmp posy, bl
    je terminaJuego
    mov ah, 02h 
    mov dl, posx 
    mov dh, posy 
    inc dh     
    int 10h ; poner cursor en la cabeza 
    mov ah, 08h ; interrupcion 10h para leer contenido del cursor 
    int 10h 
    cmp al, [cuerpo] ; la serpiente choca contra su cuerpo 
    je terminaJuego  
    ret
validarIzq: 
    cmp posx, 1 
    je terminaJuego 
    mov ah, 02h 
    mov dl, posx 
    mov dh, posy 
    dec dl    
    int 10h ; poner cursor en la cabeza 
    mov ah, 08h ; interrupcion 10h para leer contenido del cursor 
    int 10h 
    cmp al, [cuerpo] ; la serpiente choca contra su cuerpo 
    je terminaJuego
    ret 
validarDer: 
    mov bl, x 
    cmp posx, bl 
    je terminaJuego 
    mov ah, 02h 
    mov dl, posx 
    mov dh, posy 
    inc dl    
    int 10h ; poner cursor en la cabeza 
    mov ah, 08h ; interrupcion 10h para leer contenido del cursor 
    int 10h 
    cmp al, [cuerpo] ; la serpiente choca contra su cuerpo 
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

validarManzanas proc 
comp1:     
    mov dl, posx     
    cmp dl, 4
    je comp2
    ret 
comp2: ; comp1 y comp2 para comparar ambas coordenadas de manzana 1  
    mov dh, posy 
    cmp dh, 4
    je checkpoint_creceIzq2
    ret
comp3:     
    mov dl, posx     
    cmp dl, [right]
    je comp4
    ret 
comp4: ;comp3 y comp4 para comparar ambas coordenadas de manzana 2
    mov dh, posy 
    cmp dh, 4
    je checkpoint_creceIzq
    ret
comp5:     
    mov dl, posx     
    cmp dl, [right]
    je comp6
    ret 
comp6: ;comp5 y comp6 para comparar ambas coordenadas de manzana 3
    mov dh, posy 
    cmp dh, [bottom]
    je checkpoint_creceIzq
    ret
comp7:     
    mov dl, posx     
    cmp dl, 4
    je comp8
    ret 
comp8: ;comp7 y comp8 para comparar ambas coordenadas de manzana 4
    mov dh, posy 
    cmp dh, [bottom]
    je checkpoint_creceIzq
    ret
validarManzanas endp 


checkpoint_creceIzq2:
    jmp checkpoint_creceIzq
validar_cola proc 
colaDer:
    mov ah, 02h 
    mov dl, xcola
    mov dh, ycola
    mov cBorrarX, dl
    mov cBorrarY, dh
    sub dl, -1h
    int 10h;coloco el cursor
    mov ah, 08h
    int 10h;leo el caracter que hay en el cursor
    cmp al, cuerpo
    jne colaIzq
    mov cBorrarX, dl;encuentro la posX de la nueva cola
    mov ah, 02h 
    mov dh, ycola
    mov dl, xcola 
    int 10h ; poner cursor donde ir? caracter 
    mov dl, 32
    int 21h
    mov dh, cBorrarY;Actualizo la nueva posicion de mi cola 
    mov dl, cBorrarX
    mov xcola, dl
    mov ycola, dh
    ret
checkpoint_creceIzq:
    jmp creceIzq
colaIzq:
    mov ah, 02h 
    mov dl, xcola
    mov dh, ycola
    mov cBorrarX, dl
    mov cBorrarY, dh
    sub dl, 1h
    int 10h;coloco el cursor
    mov ah, 08h
    int 10h;leo el caracter que hay en el cursor
    cmp al, cuerpo
    jne colaArr
    mov cBorrarX, dl;encuentro la posX de la nueva cola
    mov ah, 02h 
    mov dh, ycola
    mov dl, xcola 
    int 10h ; poner cursor donde ir? caracter 
    mov dl, 32
    int 21h
    mov dh, cBorrarY;Actualizo la nueva posicion de mi cola 
    mov dl, cBorrarX
    mov xcola, dl
    mov ycola, dh
    ret
checkpoint_colaAb:
    jmp colaDer
colaArr:
     mov ah, 02h 
    mov dl, xcola
    mov dh, ycola
    mov cBorrarX, dl
    mov cBorrarY, dh
    sub dh, 1h
    int 10h;coloco el cursor
    mov ah, 08h
    int 10h;leo el caracter que hay en el cursor
    cmp al, cuerpo
    jne colaAb
    mov cBorrarY, dh;encuentro la posY de la nueva cola
    mov ah, 02h 
    mov dh, ycola
    mov dl, xcola 
    int 10h ; poner cursor donde ir? caracter 
    mov dl, 32
    int 21h
    mov dh, cBorrarY;Actualizo la nueva posicion de mi cola 
    mov dl, cBorrarX
    mov xcola, dl
    mov ycola, dh
    ret
colaAb:
    mov ah, 02h 
    mov dl, xcola
    mov dh, ycola
    mov cBorrarX, dl
    mov cBorrarY, dh
    sub dh, -1h
    int 10h;coloco el cursor
    mov ah, 08h
    int 10h;leo el caracter que hay en el cursor
    cmp al, cuerpo
    jne checkpoint_colaAb
    mov cBorrarY, dh;encuentro la posX de la nueva cola
    mov ah, 02h 
    mov dh, ycola
    mov dl, xcola 
    int 10h ; poner cursor donde ir? caracter 
    mov dl, 32
    int 21h
    mov dh, cBorrarY;Actualizo la nueva posicion de mi cola 
    mov dl, cBorrarX
    mov xcola, dl
    mov ycola, dh
    ret
validar_cola endp    

agregarNuevaCola proc
creceIzq:
    dec contManzana
    mov bl, contManzana
    cmp bl, 0 
    je mandar 
    mov ah, 02h 
    mov dl, xcola
    mov dh, ycola
    sub dl, -1h
    int 10h;coloco el cursor
    mov ah, 08h
    int 10h;leo el caracter que hay en el cursor
    cmp al, cuerpo
    jne creceDer
    mov ah, 02h 
    mov dh, ycola
    mov dl, xcola 
    sub dl, 1h
    mov xcola, dl
    mov ycola, dh
    int 10h ; poner cursor donde ir? caracter 
    mov ah, 02h
    mov dl, cuerpo
    int 21h
    ret
mandar: 
    jmp reaparecer
creceDer:
    dec contManzana
    mov bl, contManzana
    cmp bl, 0 
    je mandar2 
    mov ah, 02h 
    mov dl, xcola
    mov dh, ycola
    sub dl, 1h
    int 10h;coloco el cursor
    mov ah, 08h
    int 10h;leo el caracter que hay en el cursor
    cmp al, cuerpo
    jne creceArr
    mov ah, 02h 
    mov dh, ycola
    mov dl, xcola 
    sub dl, -1h
    mov xcola, dl
    mov ycola, dh
    int 10h ; poner cursor donde ir? caracter 
    mov ah, 02h
    mov dl, cuerpo
    int 21h
    ret
mandar2: 
    jmp reaparecer
checkpoint_creceDer:
    jmp creceDer
creceArr:
    dec contManzana
    mov bl, contManzana
    cmp bl, 0 
    je reaparecer 
    mov ah, 02h 
    mov dl, xcola
    mov dh, ycola
    sub dh, -1h
    int 10h;coloco el cursor
    mov ah, 08h
    int 10h;leo el caracter que hay en el cursor
    cmp al, cuerpo
    jne creceAb
    mov ah, 02h 
    mov dh, ycola
    mov dl, xcola 
    sub dh, 1h
    mov xcola, dl
    mov ycola, dh
    int 10h ; poner cursor donde ir? caracter 
    mov ah, 02h
    mov dl, cuerpo
    int 21h
    ret
creceAb:
    dec contManzana
    mov bl, contManzana
    cmp bl, 0 
    je reaparecer 
    mov ah, 02h 
    mov dl, xcola
    mov dh, ycola
    sub dh, 1h
    int 10h;coloco el cursor
    mov ah, 08h
    int 10h;leo el caracter que hay en el cursor
    cmp al, cuerpo
    jne checkpoint_creceDer
    mov ah, 02h 
    mov dh, ycola
    mov dl, xcola 
    sub dh, -1h
    mov xcola, dl
    mov ycola, dh
    int 10h ; poner cursor donde ir? caracter 
    mov ah, 02h
    mov dl, cuerpo
    int 21h
    ret
agregarNuevaCola endp

reaparecer: 
    mov contManzana, 4 
    call imprimirManzanas
    ret 

SALTOLINEA proc 
    ; imprimir un salto de linea antes de mostrar un resultado
    MOV DL, 10
    MOV AH, 02
    INT 21h
    MOV DL, 13
    INT 21H
    XOR AX, AX 
    ret   
SALTOLINEA endp

limpiar proc 
    mov ah, 02h 
    mov dh, [msgy]
    mov dl, [msgx]
    int 10h ;colocar cursor 
    mov ah, 09
    lea dx, [clean]
    int 21h 
    ret
limpiar endp 

dim proc far 
    lea dx, dimensiones
    mov ah, 09h 
    int 21h 
    jmp FIN 
    ret
dim endp 

FIN proc far  
    MOV AH, 4CH 
    INT 21H
FIN endp

end programa
	.386P
	.MODEL	SMALL, SYSCALL

	.CODE

	public	NoLanguage	Expand

;*──────────────────────────────────────────────────────────────────────────*

Expand	PROC USES ESI EDI EBX EBP,\
	src:DWORD, dest:DWORD, count:DWORD   ; COUNT devrait etre un DWORD !!!

	mov	esi, src
	mov	edi, dest
	mov	ebp, count		; compteur pour savoir si on a fini... ; counter to know whether the loop ends or not
					; et puis j'ai plus besoin de lire ; and I don't need to read other parameters anymore, thus BP (decompression size)
					; d'autre parametres... d'ou BP !
					; BP = decomp size
boucle:
	mov	dx, 8			; 1 octet info pour 8 data de 8 ou ; 1  byte of information for 8 data of 8 or 16 bytes (depends on the bit)
					; 16 bits (ca depend du bit...)
	lodsb
	mov	bx, ax			; octet d'info dans bl ; 1 byte of info in BL
next:
	shr	bx, 1			; ca va plus vite de décaler bx ou ; is it faster to shift BX or BL?
					; bl ? (Vrai question, chef)
	jnc	copie			; chaque bit indique la nature de ; each byte indicates the nature of what follows
					; ce qui suit

	movsb				; ici un octet de data a recopier ; here, a byte of data to copy
	dec	ebp			; 1 de moins ; 1 less
	jz	termine			; si c'est fini, c'est fini ; if it's the end, it's the end
	dec	dx			; 1 bit de moins ; 1 byte less
	jnz	next			; s'il en reste on continu ; if there's more, we continue
	jmp	boucle			; sinon on lit un octet d'info de plus ; else, we read another byte of info

copie:					; ici on a 16 bits formant un offset
					; (sur 12 bits) et une longueur					; (sur 4 bits) ; here we have 16 bits with an offset (on 12 bits) and a length (on 4 bits)
	lodsw				; on lit donc cette donnee ; we read this piece of data
	movzx	ecx, ax
	mov	eax, ecx
	and	ecx, 0Fh		; on recupere la longueur dans cx ; we get the length from CX
	inc	ecx			; on ajuste car pas de copie de ; we adjust because we don't copy blocks of length < 2 (thus gain)
	inc	ecx			; bloc de longeur < 2 (d'ou gain...)
	sub	ebp, ecx		; il restera ca en moins a faire ; this means less to do later
	shr	eax, 4			;
					; on recupere l'offset ; we get the offset
	not	eax			; en fait c'est un decalage en ; actually, it's a shift backwards - 1 (NOT ax = -ax - 1)
					; arrière - 1 (not ax = -ax - 1)
	add	eax, edi		; par rapport à di (ax = di - ax - 1) ; compared to DI (ax = di - ax - 1) we save if ####### sentence
	xchg	eax, esi		; on sauve si tout en lui donnant
					; l'ofset calcule
	rep	movsb			; on fait la recopie ; we copy

	mov	esi, eax		; restore si ; restore if we have more?
	or	ebp, ebp		; il en reste ?
	jz	termine			; ...
	dec	dx			; il reste des bits d'info ? ; do we have more info bytes?
	jnz	next                    ; ...
	jmp	boucle                  ; ...
termine:				; c'est fini... Quoi ?!!! deja ?!!! ; we're done. what? already? this compression method is dumb! but it works!
					; c'est con cette methode de
					; compression ! Mais ca marche !
	ret

Expand	ENDP


	end

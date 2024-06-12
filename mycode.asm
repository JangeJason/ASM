; multi-segment executable file template.

data segment
    file db "d:\words.txt", 0 
    file_code dw ?
    words_number dw 0 
    buf db 128 dup(" ")
    words db 6400 dup(" ")
    insert_place dw 0
    likely dw 0
    likely_pos dw -1
    exist dw 0
    find1_or_delete0 dw 1 
    str0 db "Dictionary$"
    str1n0 db "Exit   : 1$"
    str1n1 db "Search: 2$"
    str1n2 db "input  : 3$"
    str1n3 db "Edit   : 4$"
    str1n4 db "Delete: 5$"
    str1n5 db "Choose : $"
    fun1 db "Search:$"
    fun2 db "Input:$"
    fun3 db "Edit$"
    fun4 db "Delete:$"
    str2 db "Explain:$"
    str3 db "Synonym:$"
    str4 db "Antonym:$"
    str5 db "Thanks for your using!$"
    str6 db "Bye~$"
    choose_error db "Please choose 1 to 5!$"
    press_return db "Press any key to return!$"
    waiting_msg db "Enter the infomations!$"
    find_msg db "Deleting the word...$"
    searching_msg db "Searching! Please wait!$"
    word_exist db "Word already exists!$"
    nofound_msg db "Can not find the word!  Press any to continue...$"
    success_msg db "Success!  Press any key to return!$"
    search_like_msg db "Not Found! But the related words are below:$"
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here
            
scroll macro n, ulr, ulc, lrr, lrc, att           ;�������Ͼ�궨��
    mov ah, 6                                     ;�������Ͼ�
    mov al, n                                     ;N=�Ͼ�������N=0����
    mov ch, ulr                                   ;���Ͻ��к�
    mov cl, ulc                                   ;���Ͻ��к�
    mov dh, lrr                                   ;���½��к�
    mov dl, lrc                                   ;���½��к�
    mov bh, att                                   ;����������
    int 10h
endm
   
curse macro cury, curx
    mov ah, 2                                     ;�ù��λ��
    mov dh, cury                                  ;�к�
    mov dl, curx                                  ;�к�
    mov bh, 0                                     ;��ǰҳ
    int 10h
endm
    
input_word macro begin, len                         ;���뵥�ʡ����͵�
local next, now_place, compare, move_loop, insert_loop, other, move, insert, result, additional, exist, exit
    mov ah, 0ah                                   ;����
    lea dx, buf
    int 21h
    mov ax, begin
    cmp ax, 0
    jnz next
    call waiting
next:
    mov bl, begin                               
    sub bl, 0                                     ;�ж��ǲ������뵥��
    jnz insert                                    ;������ֱ�Ӳ���
    cld                                           ;������Ҫ�ҵ����Ĳ��룬����ԭ����������ƶ�����λ��
    mov cx, words_number                                   ;�Ѵ洢�ĵ�������                            
now_place:                                      
    cmp cx, 0
    jz additional                                 
    push cx                                   ;�洢�Ѿ����ʵ��ڼ�������            
    mov ax, cx                            
    dec ax
    xor bx, bx
    mov bl, 100                             
    mul bl                                    ;��¼��cx-1(��Ϊ�±��0��ʼ)�����ʵ��׵�ַ 
    mov di, ax                            
    lea si, buf[2]                           ;���ʵĵ�һ����ĸ��ַ
    mov cl, [si-1]                            ;�������ʵĳ���          
compare:
    lodsb
    cmp al, words[di]                     ;�ӵ�һ����ĸ��ʼһ�αȽ�
    jb result                               ;��Ϊ�ǴӺ���ǰ�Ƚϣ���������¼���Ĵ�С������ڲ�ѭ��
    cmp al, words[di]
    ja move                               ;���ڵ�ǰ�������ѭ�����в��루��Ϊ��һ���ж��Ѿ�ȷ��С�ں�һ���ʣ�,���ڵ�cx+1��words[cx]
    inc di
    loop compare                             ;���������ڲ�ѭ��
    cmp words[di], ' '                    ;word������ȫ��ͬ�����ж�words�Ƿ����
    jz exist
result:
    pop cx
    loop now_place
    push cx
    jmp move
additional:
    push 0
    jmp insert
exist:
    scroll 23, 5, 40, 9, 78, 0B0h        ;��������               
    curse 6, 56
    mov ah, 09h
    lea dx, word_exist
    int 21h
    curse 8, 56
    mov ah, 09h
    lea dx, press_return
    int 21h
    mov ah, 0                         ;�ȴ�����
    int 16h       
    scroll 23, 5, 40, 9, 78, 0B0h
    scroll 23, 5, 1, 9, 38, 0B0h            
    call choose_bar
    mov word_exist, 1
    jmp exit
move:
    std                                       ;si��di�ݼ�
    mov ax, words_number                               ;ȡ���ܹ���������
    xor bx, bx
    mov bl, 100
    mul bl                                    ;����ܹ������ֽ�
    lea bx, words                             ;ȡ��words��ַ
    add ax, bx                                ;���ϱ�ַ�õ����һ�����ʵĺ�һ�����ʵĵ�ַ
    dec ax                                    ;��һ�õ����һ�����ʵ����һ����ĸ
    mov si, ax
    add ax, 100                               ;ÿ����Ҫ�ƶ�100λ
    mov di, ax
    mov ax, words_number                               ;ȡ���ܹ���������
    pop cx                                    ;��ǰҪ���ڵڼ������ʺ���
    sub ax, cx                                ;����Ӧ���ƶ���������
    mov insert_place, cx                               ;����һ��Ҫ�����ļ�¼�������Ա����insert
    xor bx, bx
    mov bl, 100 
    mul bl
    mov cx, ax                                ;��Ϊѭ������
    cmp cx, 0
    jz insert
move_loop:
    lodsb                                 ;��si����ÿһλ�ȱ��浽al��
    stosb                                 ;�ٰ�al�ƶ���di��ָ
    loop move_loop                              
insert:
    cld
    mov ax, insert_place
    xor bx, bx
    mov bl, 100                            
    mul bl                                ;�������ַ����Ӧ�����Ŀ�ʼ�洢
    lea bx, words
    add ax, bx
    mov bx, begin
    add ax, bx                            ;����ƫ����
    mov di, ax
    lea si, buf[2]
    xor cx, cx
    mov cl, [si-1]                        ;�ַ�������
    mov ax, len
    sub ax, cx
    push ax 
insert_loop:
    lodsb
    stosb
    loop insert_loop
    pop cx
other:
    mov al, ' '
    stosb
    loop other
exit:      
endm

edit_word macro begin, len                        ;�޸ĵ��ʡ����͵�
    local loop1, loop2
    mov ah, 0ah                                   ;����
    lea dx, buf
    int 21h
    cld 
    mov cx, insert_place 
    mov ax, cx
    dec ax
    xor bx, bx
    mov bl, 100                            
    mul bl                                        ;�������ַ����Ӧ�����Ŀ�ʼ�޸�
    lea bx, words
    add ax, bx
    mov bx, begin
    add ax, bx                                    ;����ƫ����
    mov di, ax
    lea si, buf[2]
    xor cx, cx
    mov cl, [si-1]
    mov ax, len                                   ;����ʣ�¶����ַ���Ҫ��Ϊ��
    sub ax, cx
    push ax 
loop1:
    lodsb
    stosb
    loop loop1
    pop cx
loop2:
    mov al, ' '
    stosb
    loop loop2
endm 

delete_word macro                                 ;����pos��λ��ɾ������
    local loop1
    mov ax, likely_pos                                   ;ɾ���ĸ�λ�õĵ���
    cld                                               
    dec ax
    xor bx, bx
    mov bl, 100
    mul bl                                        ;����ܹ������ֽ�
    lea bx, words                                 ;ȡ��words��ַ                       
    
    add ax, bx                                    ;���ϱ�ַ�õ�Ҫɾ���ĵ��ʵĵ�ַ
    mov di, ax
    add ax, 100                                   ;ÿ����Ҫ�ƶ�100λ
    mov si, ax
    mov ax, words_number                                   ;ȡ���ܹ���������
    mov cx, likely_pos                                
    sub ax, cx                                    ;������������
    inc ax                                        ;����ʵ��Ҫ�ƶ��ĵ�������
    xor bx, bx
    mov bl, 100 
    mul bl
    mov cx, ax                                    ;��Ϊѭ������
loop1:
    lodsb                                     ;��si����ÿһλ�ȱ��浽al��
    stosb                                     ;�ٰ�al�ƶ���di��ָ
    loop loop1   
endm

import:                                           ;���ļ������ֵ�����
    ;mov ah, 3ch                                  ;�½��ļ�
;    mov cx, 0
;    lea dx, file                         
;    int 21h        
    mov al, 0                                     ;�򿪷�ʽΪд
    mov ah, 3DH                                   ;���ļ�
    lea dx, file
    int 21h
    mov file_code, ax                             ;�����ļ���
    mov ah, 3FH                                   ;��ȡ�ļ�
    mov bx, file_code                             ;���ļ����Ŵ�����bx
    mov cx, 6400
    lea dx, words                                 ;���ݻ�������ַ 
    int 21h
    mov bl, 100 
    div bl                                        ;�������ȡ�˶��ٵ���
    mov words_number, ax      
    mov bx, file_code                             ;���ļ����Ŵ�����bx
    mov ah, 3EH                                   ;�ر��ļ�
    int 21h
        
ui:                                               ;����ui����
    scroll 0, 0, 0, 24, 79, 02                    ;����
    scroll 25, 0, 0, 24, 79, 0F0h                 ;���ⴰ��
    scroll 23, 1, 1, 3, 78, 0B0h                   ;����
    scroll 23, 5, 1, 9, 38, 0B0h                   ;�����
    scroll 23, 5, 40, 9, 78, 0B0h                  ;���ʲ�
    scroll 23, 11, 1, 15��78, 0B0h                 ;���Ͳ�
    scroll 23, 17, 1, 23��38, 0B0h                 ;ͬ��ʲ�
    scroll 23, 17, 40, 23, 78, 0B0h                ;����ʲ�  
    
    call init_str    

choose:
    mov ah, 0                                     ;����ѡ��
    int 16h                                           
    mov ah, 0eh                                   ;��ʾ������ַ�
    int 10h                                              
    cmp al, 49                                    ;ѡ��0,��ʾ�˳�
    jz export                               
    cmp al, 50                                    ;ѡ��1,��ʾ����
    jz search
    cmp al, 51                                    ;ѡ��2,��ʾ����
    jz input
    cmp al, 52                                    ;ѡ��3,��ʾ�޸�
    jz edit                                    
    cmp al, 53                                    ;ѡ��4,��ʾɾ��
    jz delete 
    scroll 23, 5, 1, 9, 38, 0B0h                    ;��������
    curse 6, 4  
    mov ah, 09h
    lea dx, choose_error
    int 21h
    curse 8, 4  
    mov ah, 09h
    lea dx, press_return
    int 21h                            
    mov ah, 0
    int 16h
    scroll 23, 5, 1, 9, 38, 0B0h
    call choose_bar
    jmp choose
search:
    lea dx, fun1                                 
    call init_function                                   ;���������ʾ��ǰִ�еĲ���Ϊ����
    curse 7, 56                                  
    call searching
    search_exit:
    jmp choose
input:
    mov exist, 0
    lea dx, fun2                          
    call init_function                                   ;���������ʾ��ǰִ�еĲ���Ϊ����
    curse 7, 56                                    
    input_word 0, 20                              ;���뵥��
    mov ax, exist
    cmp ax, 1
    jz input_exit                                 
    inc words_number                                       ;��������+1
    curse 13, 12
    input_word 20, 40                             ;����ע��
    curse 20, 12                                
    input_word 60, 20                             ;����ͬ���
    curse 20, 51
    input_word 80, 20                             ;���뷴���
    call input_done                                    ;��ս��
    input_exit:
    jmp choose
edit:
    lea dx, fun3                                   
    call init_function                                   ;���������ʾ��ǰִ�еĲ���Ϊ�޸�
    curse 7, 56
    call find                                     ;���ò��Һ��������ص���λ�õ�pos�����Ҳ����������ʾ��Ϣ������posΪ-1
    mov cx, likely_pos                                 
    cmp cx, -1                                    ;-1������ѯ�������˳�
    jz edit_exit                        
    mov insert_place, cx
    curse 13, 12
    edit_word 20, 40                            ;�޸Ľ��ͣ�ƫ�Ƶ�ַΪ20������40
    curse 20, 12
    edit_word 60, 20                            ;�޸�ͬ��ʣ�ƫ�Ƶ�ַΪ60������20
    curse 20, 51
    edit_word 80, 20                            ;�޸ķ���ʣ�ƫ�Ƶ�ַΪ80������20
    call input_done
    edit_exit:
    jmp choose
delete:
    lea dx, fun4                                 
    call init_function                                   ;���������ʾ��ǰִ�еĲ���Ϊɾ��
    curse 7, 56
    mov find1_or_delete0, 0                                  
    call find                                     ;���ò��Һ��������ص���λ�õ�pos�����Ҳ����������ʾ��Ϣ������posΪ-1
    mov cx, likely_pos
    cmp cx, -1                                    ;-1������ѯ�������˳�
    jz delete_exit
    delete_word                                   ;����posλ��ɾ������
    dec words_number                                       ;��������-1
    call input_done                                  
    delete_exit:
    jmp choose
export:
    lea dx, file         
    mov al, 1                                     ;�򿪷�ʽΪд
    mov ah, 3DH                                   ;���ļ�
    int 21h
    mov file_code, ax                             ;�����ļ���
    mov ax, words_number                                   ;д����ֽ���
    mov bl, 100
    mul bl
    mov cx, ax
    mov ah, 40H                                   ;д���ļ�
    mov bx, file_code                             ;���ļ����Ŵ�����bx
    lea dx, words                                 ;���ݻ�������ַ 
    int 21h       
    mov bx, file_code                             ;���ļ����Ŵ�����bx
    mov ah, 3EH                                   ;�ر��ļ�
    int 21h
           
    call exit_str                                 ;�˳���Ϣ
    mov ax, 4c00h                                 ;��������
    int 21h
                
init_str proc                                     ;��ʾ�����ַ���
    push ax
    push dx
    curse 2, 35
    mov ah, 09h                                   ;��ʾ�ֵ�
    lea dx, str0                                
    int 21h
    curse 12, 4
    mov ah, 09h                                   ;��ʾע��
    lea dx, str2
    int 21h
    curse 18, 4
    mov ah, 09h                                   ;��ʾͬ���
    lea dx, str3
    int 21h
    curse 18, 43
    mov ah, 09h                                   ;��ʾ�����
    lea dx, str4
    int 21h
    call choose_bar        
    pop dx
    pop ax
    ret
init_str endp

exit_str proc                                     ;����ҳ��
    push dx
    push ax
    scroll 0, 1, 1, 23, 78, 0B0h                   ;����
    curse 11, 28
    mov ah, 09h
    lea dx, str5
    int 21h
    scroll 1, 1, 1, 23, 78, 0B0h                   ;�Ͼ�һ��
    curse 12, 38
    mov ah, 09h
    lea dx, str6
    int 21h
    mov ah, 0                                     ;�ȴ�����
    int 16h       
    pop ax
    pop dx
    ret       
exit_str endp

choose_bar proc
    curse 5, 4     
    mov ah, 09h                                   ;��ʾѡ����Ϣ
    lea dx, str1n0
    int 21h
    curse 6, 4     
    mov ah, 09h                                   ;��ʾѡ����Ϣ
    lea dx, str1n1
    int 21h
    curse 7, 4     
    mov ah, 09h                                   ;��ʾѡ����Ϣ
    lea dx, str1n2
    int 21h
    curse 8, 4     
    mov ah, 09h                                   ;��ʾѡ����Ϣ
    lea dx, str1n3
    int 21h
    curse 9, 4     
    mov ah, 09h                                   ;��ʾѡ����Ϣ
    lea dx, str1n4
    int 21h
    curse 7, 20     
    mov ah, 09h                                   ;��ʾѡ����Ϣ
    lea dx, str1n5
    int 21h
    ret
choose_bar endp

searching proc
    push ax
    push bx
    push cx
    push dx
    mov likely, 0                               ;ģ����ѯ�������Ϊ0
    mov ah, 0ah                                   ;����
    lea dx, buf                                  
    int 21h
    call search_msg                                  ;������ʾ��Ϣ
    cld                                       
    mov cx, words_number                                   ;�Ѵ洢�ĵ�������
    cmp cx, 0
    jz notequal_search                          ;cxΪ0��϶��Ҳ�������
loop1_search:                                 
    push cx                                   ;�洢�Ѿ����ʵ��ڼ�������
    mov ax, cx                            
    dec ax
    xor bx, bx
    mov bl, 100
    mul bl                                    ;��¼��cx-1�����ʵ��׵�ַ 
    mov di, ax
    dec di                                    ;����ͳһ��1,����������ǰ��1
    xor cx, cx                                       
    lea si, buf[2]                           ;���ʵĵ�һ����ĸ��ַ
    mov cl, [si-1]                            ;�������ʵĳ���          
loop2_search:
    inc di
    lodsb
    cmp al, words[di]
    jne next_search                     ;��ǰ���ʳ�����ĸ�����,�ж���һ������
    loop loop2_search                      ;��ĸ��ȼ��������ж�
    inc di                                ;buf�����ж��꣬ȫ����ͬ�����е��˴�
    cmp words[di], ' '                    ;�ж�words�����Ƿ����
    jz search_exact                       ;������ȷ������
    pop cx
    push cx
    mov likely_pos, cx
    inc likely                          ;����ģ����ѯ�Ľ�������������һ�����ʵĲ�ѯ   
    next_search:                        ;���ֲ��������ѭ���ж���һ������
    pop cx                            
    loop loop1_search
    cmp likely, 0
    jnz search_like                       ;like_cnt��Ϊ0�����ģ����ѯ���������������Ҳ�������
notequal_search:                          ;���е��˴�˵��ƥ�䲻������
    scroll 23, 5, 1, 9, 38, 0B0h                   ;�����
    scroll 23, 5, 40, 9, 78, 0B0h                  ;���ʲ�
    scroll 23, 11, 1, 15��78, 0B0h                 ;���Ͳ�
    scroll 23, 17, 1, 23��38, 0B0h                 ;ͬ��ʲ�
    scroll 23, 17, 40, 23, 78, 0B0h                ;����ʲ�               
    curse 13, 18
    mov ah, 09h                                   ;�������ʾ�ɹ���Ϣ
    lea dx, nofound_msg
    int 21h
    mov ah, 0                             ;�ȴ�����
    int 16h       
    scroll 23, 11, 1, 15��78, 0B0h                 ;���Ͳ�
    call init_str
    jmp search_exit
search_exact:
    cld
    pop ax
    dec ax
    xor bx, bx
    mov bl, 100                            
    mul bl                                ;�������ַ����Ӧ�����Ŀ�ʼ���
    lea bx, words
    add ax, bx                            ;��������λ��
    add ax, 20                            ;��words[20]��ʼ,Ϊ����
    mov si, ax                                               
    lea di, buf
    mov cx, 40
loop_explain:                          ;�������
    lodsb
    stosb
    loop loop_explain
    curse 13, 12
    mov buf[39], '$'
    mov ah, 09h
    lea dx, buf
    int 21h
    lea di, buf
    mov cx, 20
loop_synonym:                          ;���ͬ���
    lodsb                           
    stosb
    loop loop_synonym 
    curse 20, 12
    mov buf[19], '$'
    mov ah, 09h
    lea dx, buf
    int 21h
    lea di, buf 
    mov cx, 20
loop_antonym:                          ;��������
    lodsb
    stosb
    loop loop_antonym
    curse 20, 51  
    mov buf[19], '$'
    mov ah, 09h
    lea dx, buf
    int 21h
    mov ah, 0                             ;�ȴ�����
    int 16h                             
    scroll 23, 5, 1, 9, 38, 0B0h                   ;�����
    scroll 23, 5, 40, 9, 78, 0B0h                  ;���ʲ�
    scroll 23, 11, 1, 15��78, 0B0h                 ;���Ͳ�
    scroll 23, 17, 1, 23��38, 0B0h                 ;ͬ��ʲ�
    scroll 23, 17, 40, 23, 78, 0B0h                ;����ʲ�
    call init_str
    jmp searching_exit
search_like:
    scroll 23, 11, 1, 23��78, 0B0h                 ;ǰ׺���ʲ�
    curse 13, 8
    mov ah, 09h
    lea dx, search_like_msg
    int 21h
    mov cx, likely
search_like_loop1:
    push cx
    mov ax, likely_pos
    inc likely_pos                           ;ÿ����һ��pos������һ������
    dec ax
    xor bx, bx
    mov bl, 100                            
    mul bl                            ;�������ַ����Ӧ�����Ŀ�ʼ���
    lea bx, words
    add ax, bx                        ;��������λ��
    mov si, ax                                   
    lea di, buf
    mov cx, 20
    search_like_loop2:
        lodsb
        stosb
        loop search_like_loop2
    curse 20, 14
    mov buf[19], '$'
    mov ah, 09h
    lea dx, buf                                                                        
    int 21h
    scroll 1, 15, 1, 21��78, 0B0h
    pop cx
    dec cx
    cmp cx, 0
    jnz search_like_loop1
    mov ah, 0                         ;�ȴ�����
    int 16h
    scroll 23, 11, 1, 23��78, 0FFh                 ;ǰ׺���ʲ�                     
    scroll 23, 5, 1, 9, 38, 0B0h                   ;�����
    scroll 23, 5, 40, 9, 78, 0B0h                  ;���ʲ�
    scroll 23, 11, 1, 15��78, 0B0h                 ;���Ͳ�
    scroll 23, 17, 1, 23��38, 0B0h                 ;ͬ��ʲ�
    scroll 23, 17, 40, 23, 78, 0B0h                ;����ʲ�
    call init_str                     ;��ʼ������
searching_exit:    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
searching endp

find proc                                         ;��ȷѰ�ҵ���
    push dx
    push cx
    push bx                                      
    push ax
    mov ah, 0ah                                   ;����
    lea dx, buf
    int 21h
    mov cx, find1_or_delete0
    cmp cx, 0 
    jz deleting
    jmp waiting_find
deleting:
    call delete_find
    jmp find_ok
waiting_find:
    call waiting
    jmp find_ok    
find_ok:
    cld                                       
    mov cx, words_number                                   ;�Ѵ洢�ĵ�������
    cmp cx, 0
    jz notequal_find                            ;cxΪ0��϶��Ҳ�������
loop1_find:                                 
    push cx                                   ;�洢�Ѿ����ʵ��ڼ�������
    mov ax, cx                            
    dec ax
    xor bx, bx
    mov bl, 100
    mul bl                                    ;��¼��cx-1�����ʵ��׵�ַ 
    mov di, ax
    dec di                                    ;����ͳһ��1,����������ǰ��1
    xor cx, cx                                       
    lea si, buf[2]                           ;���ʵĵ�һ����ĸ��ַ
    mov cl, [si-1]                            ;�������ʵĳ���          
loop2_find:
    inc di
    lodsb
    cmp al, words[di]
    jne out_find                       ;��ǰ���ʳ�����ĸ�����
    loop loop2_find                        ;��ĸ��ȼ��������ж�
    inc di                                ;word�����ж��꣬ȫ����ͬ�����е��˴�
    cmp words[di], ' '                    ;�ж�words�����Ƿ����
    jnz out_find                       ;û�н���������ж�
    pop cx                                ;������˵���ҵ�ƥ�䵥��
    mov likely_pos, cx
    jmp find_exit                         
out_find:                          ;���ֲ��������ѭ���ж���һ������
    pop cx                            
    loop loop1_find
notequal_find:                            ;���е��˴�˵��ƥ�䲻������
    mov likely_pos, -1
    scroll 23, 5, 1, 9, 38, 0B0h                   ;�����
    scroll 23, 5, 40, 9, 78, 0B0h                  ;���ʲ�
    scroll 23, 11, 1, 15��78, 0B0h                 ;���Ͳ�
    scroll 23, 17, 1, 23��38, 0B0h                 ;ͬ��ʲ�
    scroll 23, 17, 40, 23, 78, 0B0h                ;����ʲ�               
    curse 13, 18
    mov ah, 09h                                   ;�������ʾ�ɹ���Ϣ
    lea dx, nofound_msg
    int 21h
    mov ah, 0                             ;�ȴ�����
    int 16h       
    scroll 23, 11, 1, 15��78, 0B0h                 ;���Ͳ�
    call init_str
find_exit:                               
    pop ax
    pop bx
    pop cx
    pop dx
    ret
find endp

    
init_function proc                                       ;�����ǰ������ʾ�ַ�
    push ax
    push bx
    push cx
    push dx
    scroll 23, 5, 1, 9, 38, 0B0h
    scroll 23, 5, 40, 9, 78, 0B0h                   ;�����
    curse 7, 15                                 
    mov ah, 09h
    pop dx        
    int 21h
    pop cx
    pop bx
    pop ax
    ret
init_function endp

input_done proc
    push ax
    push bx
    push cx
    push dx
    scroll 23, 5, 1, 9, 38, 0B0h                   ;�����
    scroll 23, 5, 40, 9, 78, 0B0h                  ;���ʲ�
    scroll 23, 11, 1, 15��78, 0B0h                 ;���Ͳ�
    scroll 23, 17, 1, 23��38, 0B0h                 ;ͬ��ʲ�
    scroll 23, 17, 40, 23, 78, 0B0h                ;����ʲ�  
    curse 13, 20
    mov ah, 09h                                   ;�������ʾ�ɹ���Ϣ
    lea dx, success_msg
    int 21h
    mov ah, 0                                     ;�ȴ�����
    int 16h                                      
    scroll 23, 13, 1, 15��78, 0B0h                 ;���Ͳ�
    call init_str
    pop dx
    pop cx
    pop bx
    pop ax
    ret
input_done endp

waiting proc                                      ;�ȴ���ʾ
    push dx
    push cx
    push bx
    push ax
    curse 7, 9                                 
    mov ah, 09h
    lea dx, waiting_msg        
    int 21h
    pop ax
    pop bx
    pop cx
    pop dx
    ret
waiting endp

delete_find proc                                      ;�ȴ���ʾ
    push dx
    push cx
    push bx
    push ax
    mov find1_or_delete0, 1
    curse 7, 9                                 
    mov ah, 09h
    lea dx, find_msg        
    int 21h
    scroll 23, 11, 1, 15��78, 0B0h                 ;���Ͳ�
    scroll 23, 17, 1, 23��38, 0B0h                 ;ͬ��ʲ�
    scroll 23, 17, 40, 23, 78, 0B0h                ;����ʲ�
    pop ax
    pop bx
    pop cx
    pop dx
    ret
delete_find endp

search_msg proc                                      ;�ȴ���ʾ
    push dx
    push cx
    push bx
    push ax
    curse 7, 8                                 
    mov ah, 09h
    lea dx, searching_msg        
    int 21h
    pop ax
    pop bx
    pop cx
    pop dx
    ret
search_msg endp

ends   
end start ; set entry point and stop the assembler.

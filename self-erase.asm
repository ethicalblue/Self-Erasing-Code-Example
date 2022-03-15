;+---------------------------------------+
;| Erase procedure body code in MASM x64 |
;| Code example by Dawid Farbaniec       |
;+---------------------------------------+

extrn MessageBoxA : proc
extrn VirtualProtect : proc

.const
PAGE_EXECUTE_READWRITE equ 040h

ProcInfo struct
    bodyStart dq 0
    bodyEnd dq 0
    bodySize dq 0
ProcInfo ends

.data
szCaption db "ethical.blue", 0
szText db "This is sample procedure call.", 0
oldProtect dd 0
procInfo1 ProcInfo <0,0,0>

.code
MyProc1 proc
    mov rax, offset _ERASE_START
    mov [procInfo1.BodyStart], rax

    push rbp
    mov rbp, rsp
    
_ERASE_START:
    sub rsp, 30h
    xor r9, r9
    lea r8, szCaption
    lea rdx, szText
    xor rcx, rcx
    call MessageBoxA
    add rsp, 30h
_ERASE_END:

    leave
    
    mov rcx, offset _ERASE_END
    dec rcx
    mov [procInfo1.bodyEnd], rcx
    sub rcx, qword ptr [procInfo1.BodyStart]
    mov [procInfo1.bodySize], rcx
    ret
MyProc1 endp

Main proc
    ;sample procedure call
    sub rsp, 28h
    call MyProc1
    add rsp, 28h
    
    ;get write access to code block
    sub rsp, 28h
    mov r9, offset oldProtect 
    mov r8, PAGE_EXECUTE_READWRITE
    mov rdx, [procInfo1.bodySize]
    mov rcx, qword ptr [procInfo1.BodyStart]
    call VirtualProtect
    add rsp, 28h
    
    ;erase procedure body (fill with NOPs)
    mov rdx, [procInfo1.BodyStart]
    xor rcx, rcx
    _loop1:
    mov byte ptr [rdx + rcx * sizeof byte], 90h
    inc rcx
    cmp rcx, [procInfo1.bodySize]
    jle _loop1
    
    ;sample procedure call (after erasing)
    sub rsp, 28h
    call MyProc1
    add rsp, 28h
    
    ret
Main endp
end
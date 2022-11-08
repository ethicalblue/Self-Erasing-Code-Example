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
szText db "This is sample procedure.", 0
oldProtect dd 0
procInfo1 ProcInfo <0,0,0>

.code
MyProc1 proc
    mov rax, offset _ERASE_START
    mov [procInfo1.bodyStart], rax

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
    sub rcx, qword ptr [procInfo1.bodyStart]
    mov [procInfo1.bodySize], rcx
    ret
MyProc1 endp

Main proc
    ;sample procedure
    sub rsp, 28h
    call MyProc1
    
    ;get write access to code block
    mov r9, offset oldProtect 
    mov r8, PAGE_EXECUTE_READWRITE
    mov rdx, [procInfo1.bodySize]
    mov rcx, qword ptr [procInfo1.bodyStart]
    call VirtualProtect
    
    ;erase procedure body (fill with NOPs)
    mov rdx, [procInfo1.bodyStart]
    xor rcx, rcx
    @@:
    mov byte ptr [rdx + rcx * sizeof byte], 90h
    inc rcx
    cmp rcx, [procInfo1.bodySize]
    jle @b
    
    ;sample procedure (after erasing)
    call MyProc1

    add rsp, 28h
    ret
Main endp
end
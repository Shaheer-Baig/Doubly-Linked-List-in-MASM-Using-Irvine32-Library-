INCLUDE Irvine32.inc

; Define a ListNode structure
ListNode STRUCT
    NodeData DWORD ?
    NextPtr  DWORD ?
    PrevPtr  DWORD ?
ListNode ENDS

; Constants
TotalNodeCount = 15
NULL = 0
nodeSize = SIZEOF ListNode 

.data
    ; Memory pool for nodes
    memoryPool BYTE TotalNodeCount * nodeSize DUP(0)
    currentOffset DWORD 0

    ; Head and Tail pointers
    head DWORD NULL
    tail DWORD NULL

    ; User input variables
    userChoice DWORD ?
    nodeInput DWORD ?

    ; Messages
    menuMsg BYTE "Choose an option:", 0Dh, 0Ah,
             "1. Add a node", 0Dh, 0Ah,
             "2. Delete a node", 0Dh, 0Ah,
             "3. Traverse forward", 0Dh, 0Ah,
             "4. Traverse backward", 0Dh, 0Ah,
             "5. Display the entire list", 0Dh, 0Ah,
             "6. Exit", 0Dh, 0Ah, 0
    emptyListMsg BYTE "The linked list is empty.", 0
    promptCountMsg BYTE "Enter the number of nodes to add (max 15): ", 0
    promptDataMsg BYTE "Enter node data: ", 0
    deletePromptMsg BYTE "Enter the value to delete: ", 0
    nodeDeletedMsg BYTE "Node deleted.", 0
    nodeNotFoundMsg BYTE "Node not found.", 0
    traverseMsg BYTE "Traversing forward:", 0
    reverseMsg BYTE "Traversing backward:", 0
    fullListMsg BYTE "Complete linked list:", 0
    memoryFullMsg BYTE "Memory pool exhausted. Program exiting.", 0

.code

main PROC
MenuLoop:
    ; Display the menu
    mov edx, OFFSET menuMsg
    call WriteString

    ; Get user choice
    call ReadInt
    mov userChoice, eax

    ; Process user choice
    cmp userChoice, 1
    je AddNodeOption
    cmp userChoice, 2
    je DeleteNodeOption
    cmp userChoice, 3
    je TraverseForwardOption
    cmp userChoice, 4
    je TraverseBackwardOption
    cmp userChoice, 5
    je DisplayListOption
    cmp userChoice, 6
    je ExitProgram
    jmp MenuLoop

AddNodeOption:
    ; Prompt for the number of nodes to add
    mov edx, OFFSET promptCountMsg
    call WriteString
    call ReadInt
    mov ecx, eax         ; Store user input in ECX as the count

    ; Check if input exceeds the maximum allowed nodes
    cmp ecx, TotalNodeCount
    jle ContinueAdding
    mov ecx, TotalNodeCount

ContinueAdding:
    ; Loop to add nodes
AddNodesLoop:
    cmp ecx, 0           ; Check if all nodes are added
    je MenuLoop

    ; Prompt for node data
    mov edx, OFFSET promptDataMsg
    call WriteString
    call ReadInt
    mov nodeInput, eax   ; Store user input in nodeInput

    ; Add the node
    mov eax, nodeInput
    call AddNode

    dec ecx              ; Decrement the count
    jmp AddNodesLoop

DeleteNodeOption:
    ; Prompt for the value to delete
    mov edx, OFFSET deletePromptMsg
    call WriteString
    call ReadInt
    mov nodeInput, eax         ; Store user input in nodeInput
    mov eax, [nodeInput]       ; Load the value into EAX
    call DeleteNode
    jmp MenuLoop

TraverseForwardOption:
    ; Check if the list is empty
    cmp head, NULL
    je ListEmpty

    ; Traverse forward
    mov edx, OFFSET traverseMsg
    call WriteString
    call CrLf
    call TraverseForward
    jmp MenuLoop

TraverseBackwardOption:
    ; Check if the list is empty
    cmp tail, NULL
    je ListEmpty

    ; Traverse backward
    mov edx, OFFSET reverseMsg
    call WriteString
    call CrLf
    call TraverseBackward
    jmp MenuLoop

DisplayListOption:
    ; Check if the list is empty
    cmp head, NULL
    je ListEmpty

    ; Display the complete linked list
    mov edx, OFFSET fullListMsg
    call WriteString
    call CrLf
    call DisplayLinkedList
    jmp MenuLoop

ListEmpty:
    ; Display empty list message
    mov edx, OFFSET emptyListMsg
    call WriteString
    call CrLf
    jmp MenuLoop

ExitProgram:
    exit
main ENDP

; AddNode: Adds a node to the end of the doubly linked list
; Inputs: EAX (data to store in the new node
AddNode PROC
    ; Check if memory pool is full
    cmp currentOffset, TotalNodeCount * nodeSize    ;compares current node size with total size 
    jae MemoryFull                                  ;if greater then or equal to jump there 

    ; Get address for new node
    lea ebx, memoryPool             ;loads the address of memory pool into ebx
    add ebx, currentOffset          ;move ebx to that position where new node will be stored
    add currentOffset, nodeSize     ;update current offset to next free space

    ; Set NodeData
    mov [ebx].ListNode.NodeData, eax    ;moves input data which is in eax to ebx

    ; Set NextPtr and PrevPtr to NULL
    mov [ebx].ListNode.NextPtr, NULL    ;sets the next ptr to null
    mov [ebx].ListNode.PrevPtr, NULL    ;sets the prev ptr to null

    ; If the list is empty, set head and tail to this node
    cmp head, NULL
    je FirstNode

    ; Link new node to the current tail
    mov eax, tail   
    mov [eax].ListNode.NextPtr, ebx     ;sets the next ptr of current tail to new node 
    mov [ebx].ListNode.PrevPtr, eax     ;sets the new node prev ptr to currents tail
    mov tail, ebx
    ret

FirstNode:  ;incase list is empty
    mov head, ebx   ;head = new node
    mov tail, ebx   ;tail= new node 
    ret

MemoryFull:     ;if memory full display message
    mov edx, OFFSET memoryFullMsg
    call WriteString
    call CrLf
    exit
AddNode ENDP

; DeleteNode: Deletes a node based on its value
; Inputs: EAX (value to delete)

DeleteNode PROC
    mov esi, head       ; Start at the head of the list
    mov edi, 0          ; Flag to indicate if node is found

DeleteLoop:
    cmp esi, NULL       ; Check if end of list
    je NotFound

    mov ebx, [esi].ListNode.NodeData            ;ebx may current node ka data mov kiya
    cmp ebx, eax                                ;eax may wo value hy jo humnay input ki hy usay compare
    je FoundNode                                ;jumps to foundnode 

    ; Move to the next node
    mov esi, [esi].ListNode.NextPtr             ;moves to the next node of current node
    jmp DeleteLoop

FoundNode:
    ; Adjust pointers to remove the node
    mov edi, 1                          ; Set flag to indicate node is found
    mov ebx, [esi].ListNode.PrevPtr     ;stores prev node add
    mov ecx, [esi].ListNode.NextPtr     ;ecx may current k next ka address

    ; Update previous node's NextPtr if it exists
    cmp ebx, NULL                           ;agar head delete horaha ho ya curr ka prev NULL ho
    je UpdateHead                           ; If deleting the head
    mov [ebx].ListNode.NextPtr, ecx         ;prev ka next = curr ka next
    jmp SkipHeadUpdate

UpdateHead:
    mov head, ecx        ; Update head if it's the first node

SkipHeadUpdate:
    ; Update next node's PrevPtr if it exists
    cmp ecx, NULL   ; if node is tail
    je UpdateTail ; If deleting the tail
    mov [ecx].ListNode.PrevPtr, ebx     ;sets prev ka next node to curr ka next
    jmp SkipTailUpdate

UpdateTail:
    mov tail, ebx        ; Update tail if it's the last node

SkipTailUpdate:
    ; Node successfully deleted     ;display deletion message
    mov edx, OFFSET nodeDeletedMsg
    call WriteString
    call CrLf
    ret

NotFound:
    ; Check if the node was not found   ;not found update make edi 0
    cmp edi, 0
    jne EndDelete

    ; Node not found message
    mov edx, OFFSET nodeNotFoundMsg
    call WriteString
    call CrLf

EndDelete:
    ret
DeleteNode ENDP


; TraverseForward: Displays all node data in forward order

TraverseForward PROC
    mov esi, head   ;head moved in esi
TraverseLoop:
    cmp esi, NULL   ;last node      
    je TraverseEnd

    ; Display the node data
    mov eax, [esi].ListNode.NodeData
    call WriteDec
    call CrLf

    ; Move to the next node
    mov esi, [esi].ListNode.NextPtr
    jmp TraverseLoop

TraverseEnd:
    ret
TraverseForward ENDP


; TraverseBackward: Displays all node data in reverse order

TraverseBackward PROC
    mov esi, tail
TraverseBackLoop:
    cmp esi, NULL
    je TraverseBackEnd

    ; Display the node data
    mov eax, [esi].ListNode.NodeData
    call WriteDec
    call CrLf

    ; Move to the previous node
    mov esi, [esi].ListNode.PrevPtr
    jmp TraverseBackLoop

TraverseBackEnd:
    ret
TraverseBackward ENDP


; DisplayLinkedList: Displays the entire linked list in a single line

DisplayLinkedList PROC
    mov esi, head
DisplayLoop:
    cmp esi, NULL
    je DisplayEnd

    ; Display the node data
    mov eax, [esi].ListNode.NodeData
    call WriteDec
    mov al, ' '    ;space k lay
    call WriteChar

    ; Move to the next node
    mov esi, [esi].ListNode.NextPtr
    jmp DisplayLoop

DisplayEnd:
    call CrLf
    ret
DisplayLinkedList ENDP

END main

# Doubly-Linked-List-in-MASM-Using-Irvine32-Library-
"This MASM-based doubly linked list manages up to 15 nodes using a fixed memory pool, avoiding dynamic allocation. It supports adding, deleting, and traversing nodes in both directions. Built with the Irvine32 library, it efficiently demonstrates fundamental linked list operations with manual memory handling."

This document explains the **doubly linked list** implementation in MASM (x86 assembly) using the Irvine32 library. The implementation utilizes a **preallocated memory pool** instead of dynamic memory allocation methods like `malloc`. The program supports operations such as **adding, deleting, and traversing** nodes in both forward and backward directions.

---

## Data Structures Used

### ListNode (Node Structure)
A **doubly linked list** consists of nodes that contain:
- **NodeData (DWORD)** → Stores the integer value.
- **NextPtr (DWORD)** → Points to the next node.
- **PrevPtr (DWORD)** → Points to the previous node.

```assembly
ListNode STRUCT
    NodeData DWORD ?
    NextPtr  DWORD ?
    PrevPtr  DWORD ?
ListNode ENDS
```

### Global Variables
- **memoryPool** → A fixed-size memory space allocated for 15 nodes.
- **currentOffset** → Tracks the next available space in `memoryPool`.
- **head** / **tail** → Pointers to the first and last nodes in the list.
- **userChoice** → Stores user-selected menu options.
- **nodeInput** → Holds user input values for new nodes.

---

## Program Execution

### Main Menu (`main PROC`)
The program presents a menu and waits for **user input**. The selected option directs execution to the corresponding function:

- **1 → Add Node**
- **2 → Delete Node**
- **3 → Traverse Forward**
- **4 → Traverse Backward**
- **5 → Display Entire List**
- **6 → Exit Program**

---

## Function Breakdown

### Adding a Node (`AddNode PROC`)
The `AddNode` procedure:
1. **Checks memory availability**: Ensures space is available in the preallocated memory pool.
2. **Allocates a new node**: Stores user input data in a new node.
3. **Updates pointers**:
   - If the list is empty, the new node becomes both `head` and `tail`.
   - Otherwise, the new node is appended at the end, updating the previous `tail` pointer.

---

### Deleting a Node (`DeleteNode PROC`)
The `DeleteNode` procedure:
1. **Searches for a matching node** by comparing values.
2. **Updates adjacent node pointers** to bypass the deleted node.
3. **Handles special cases**:
   - If the node is at the beginning (`head`), updates the `head` pointer.
   - If the node is at the end (`tail`), updates the `tail` pointer.
4. The deleted node is no longer accessible but remains in memory.

---

### Traversing the List (`TraverseForward` & `TraverseBackward`)
Traversal operations allow for displaying the list in both directions:

- **Forward Traversal:** Starts from `head` and follows the `NextPtr` links.
- **Backward Traversal:** Starts from `tail` and follows the `PrevPtr` links.

---

## Summary

### Features
- **Efficient Doubly Linked List Implementation in Assembly**
- **Memory-Conscious**: Uses a **fixed memory pool** instead of dynamic allocation.
- **Supports Insert, Delete, and Traversal Operations**

### Limitations
- Maximum **15 nodes** due to static memory allocation.
- **No dynamic memory allocation support** (`malloc`/`realloc` equivalent is not used).


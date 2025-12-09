# INT 10h - Video BIOS Services Complete Reference

## Table of Contents
1. [Introduction](#introduction)
2. [Service Overview](#service-overview)
3. [Service Details](#service-details)
4. [Code Examples](#code-examples)
5. [Quick Reference Tables](#quick-reference-tables)
6. [Tips and Best Practices](#tips-and-best-practices)

---

## Introduction

**INT 10h** is the BIOS interrupt for video services in DOS and early operating systems. It provides low-level control over the video display, allowing programs to: 
- Set video modes (text vs graphics)
- Control cursor position and shape
- Display characters with colors
- Scroll the screen
- Draw graphics pixels
- And much more!

This repository contains **fully commented assembly programs** demonstrating each major INT 10h service. Every line has verbose educational comments explaining what it does and why. 

---

## Service Overview

| Service | Function | Description |
|---------|----------|-------------|
| **00h** | Set Video Mode | Switch between text and graphics modes |
| **01h** | Set Cursor Shape | Change cursor appearance (block, underline, hidden) |
| **02h** | Set Cursor Position | Move cursor to specific row/column |
| **03h** | Get Cursor Position | Read current cursor location and shape |
| **06h** | Scroll Up | Scroll window up or clear screen |
| **07h** | Scroll Down | Scroll window down |
| **09h** | Write Char+Attribute | Write character with specific color |
| **0Ah** | Write Char Only | Write character, preserve existing color |
| **0Ch** | Write Graphics Pixel | Draw individual pixel in graphics mode |
| **0Eh** | Teletype Output | Write character with auto cursor advance |

---

## Service Details

### Service 00h - Set Video Mode
**File:** `service_00h_set_video_mode.asm`

**Purpose:** Changes the video display mode (text or graphics).

**Registers:**
```
AH = 00h
AL = Video mode number
```

**Common Video Modes:**
- `00h`: 40x25 text, 16 colors
- `03h`: 80x25 text, 16 colors (most common)
- `13h`: 320x200 graphics, 256 colors (popular for games)

**Example:**
```asm
mov ah, 00h    ; Set video mode function
mov al, 03h    ; Mode 03h (80x25 text)
int 10h        ; Call BIOS
```

---

### Service 01h - Set Cursor Shape
**File:** `service_01h_set_cursor_shape.asm`

**Purpose:** Changes the cursor appearance by setting start/end scan lines. 

**Registers:**
```
AH = 01h
CH = Cursor start scan line (0-15)
CL = Cursor end scan line (0-15)
```

**Common Cursor Shapes:**
- Block cursor: `CH=00h, CL=07h`
- Default underline: `CH=06h, CL=07h`
- Hidden cursor: `CH=20h` (bit 5 set)

**Example:**
```asm
mov ah, 01h    ; Set cursor shape
mov ch, 00h    ; Start line 0
mov cl, 07h    ; End line 7 (block cursor)
int 10h        ; Call BIOS
```

---

### Service 02h - Set Cursor Position
**File:** `service_02h_set_cursor_position.asm`

**Purpose:** Moves the cursor to a specific row and column on the screen.

**Registers:**
```
AH = 02h
BH = Page number (usually 0)
DH = Row (0-24 for 80x25 mode)
DL = Column (0-79 for 80x25 mode)
```

**Screen Coordinates:**
- (0,0) = Top-left corner
- (24,79) = Bottom-right corner
- (12,40) = Center of screen

**Example:**
```asm
mov ah, 02h    ; Set cursor position
mov bh, 00h    ; Page 0
mov dh, 12     ; Row 12 (middle)
mov dl, 40     ; Column 40 (center)
int 10h        ; Call BIOS
```

---

### Service 03h - Get Cursor Position
**File:** `service_03h_get_cursor_position.asm`

**Purpose:** Reads the current cursor position and shape.

**Registers:**
```
Input:
  AH = 03h
  BH = Page number

Output:
  CH = Cursor start scan line
  CL = Cursor end scan line
  DH = Row
  DL = Column
```

**Example:**
```asm
mov ah, 03h    ; Get cursor position
mov bh, 00h    ; Page 0
int 10h        ; Call BIOS
; DH now contains row, DL contains column
```

---

### Service 06h/07h - Scroll Window
**File:** `service_06h_07h_scroll_window.asm`

**Purpose:** Scrolls a rectangular window up (06h) or down (07h). When AL=0, clears the window.

**Registers:**
```
AH = 06h (scroll up) or 07h (scroll down)
AL = Number of lines (0 = clear entire window)
BH = Attribute for blank lines (color)
CH = Top row of window
CL = Left column of window
DH = Bottom row of window
DL = Right column of window
```

**Clear Screen (Preferred Method):**
```asm
mov ah, 06h    ; Scroll up
mov al, 00h    ; Clear entire window
mov bh, 07h    ; White on black
mov ch, 00h    ; Top row 0
mov cl, 00h    ; Left column 0
mov dh, 24     ; Bottom row 24
mov dl, 79     ; Right column 79
int 10h        ; Clear screen
```

---

### Service 09h - Write Character and Attribute
**File:** `service_09h_write_char_attribute.asm`

**Purpose:** Writes a character with a specific color attribute at the cursor position.  Cursor does NOT advance.

**Registers:**
```
AH = 09h
AL = Character to write
BH = Page number
BL = Attribute (color byte)
CX = Repeat count
```

**Attribute Byte (BL):**
```
Bit 7: Blink (1=blink, 0=normal)
Bits 6-4: Background color (0-7)
Bits 3-0: Foreground color (0-15)
```

**Example:**
```asm
mov ah, 09h    ; Write char with attribute
mov al, 'A'    ; Character 'A'
mov bh, 00h    ; Page 0
mov bl, 0Ch    ; Light red on black (1100b)
mov cx, 05h    ; Write 5 times
int 10h        ; Display "AAAAA" in red
```

---

### Service 0Ah - Write Character Only
**File:** `service_0Ah_write_char_only. asm`

**Purpose:** Writes a character WITHOUT changing the color attribute. Preserves existing colors.  Cursor does NOT advance.

**Registers:**
```
AH = 0Ah
AL = Character to write
BH = Page number
CX = Repeat count
(BL is ignored - existing color preserved)
```

**Use Cases:**
- Overwriting text on colored backgrounds
- Updating text in colored areas
- Changing characters while keeping colors

**Example:**
```asm
mov ah, 0Ah    ; Write char only
mov al, 'X'    ; Character 'X'
mov bh, 00h    ; Page 0
mov cx, 01h    ; Write once
int 10h        ; Write 'X', keep existing color
```

---

### Service 0Ch - Write Graphics Pixel
**File:** `service_0Ch_write_graphics_pixel.asm`

**Purpose:** Draws a single pixel at specified coordinates in graphics mode. 

**Registers:**
```
AH = 0Ch
AL = Pixel color value
BH = Page number
CX = X coordinate (column)
DX = Y coordinate (row)
```

**Mode 13h (320x200x256):**
- CX range: 0-319
- DX range: 0-199
- AL range: 0-255 (color)

**Example:**
```asm
; First, set graphics mode
mov ah, 00h
mov al, 13h    ; Mode 13h (320x200x256)
int 10h

; Draw red pixel at (100, 100)
mov ah, 0Ch    ; Write pixel
mov al, 04h    ; Red color
mov bh, 00h    ; Page 0
mov cx, 100    ; X coordinate
mov dx, 100    ; Y coordinate
int 10h        ; Draw pixel
```

---

### Service 0Eh - Teletype Output
**File:** `service_0Eh_teletype_output. asm`

**Purpose:** Writes a character at cursor position and automatically advances cursor. Interprets control characters.

**Registers:**
```
AH = 0Eh
AL = Character to write
BH = Page number
BL = Foreground color (graphics modes)
```

**Control Characters:**
- `07h` (BEL): Bell/beep
- `08h` (BS): Backspace
- `09h` (TAB): Tab (next 8-column boundary)
- `0Ah` (LF): Line feed
- `0Dh` (CR): Carriage return

**Example:**
```asm
mov ah, 0Eh    ; Teletype output
mov al, 'H'    ; Character 'H'
mov bh, 00h    ; Page 0
mov bl, 0Fh    ; White color
int 10h        ; Display 'H', cursor advances

; Print newline
mov al, 0Dh    ; Carriage return
int 10h
mov al, 0Ah    ; Line feed
int 10h
```

---

## Code Examples

All example programs follow the same structure:

```asm
. model small           ; Memory model
.stack 100h            ; Stack size

.data                  ; Data segment
    ; Variables here

.code                  ; Code segment
    mov ax, @data
    mov ds, ax
    
    ; Your code here
    
    mov ah, 4ch        ; Exit
    int 21h
end
```

### Running the Examples

1. **Assemble:**
   ```
   tasm filename.asm
   ```

2. **Link:**
   ```
   tlink filename.obj
   ```

3. **Run:**
   ```
   filename.exe
   ```

---

## Quick Reference Tables

### Video Mode Reference
| Mode | Type | Resolution | Colors | Description |
|------|------|------------|--------|-------------|
| 00h | Text | 40x25 | 16 | 40-column text |
| 03h | Text | 80x25 | 16 | Standard text mode |
| 04h | Graphics | 320x200 | 4 | CGA graphics |
| 13h | Graphics | 320x200 | 256 | VGA graphics (popular) |
| 12h | Graphics | 640x480 | 16 | VGA high-res |

### Color Attribute Values
| Value | Color | Value | Color |
|-------|-------|-------|-------|
| 0 | Black | 8 | Dark Gray |
| 1 | Blue | 9 | Light Blue |
| 2 | Green | 10 | Light Green |
| 3 | Cyan | 11 | Light Cyan |
| 4 | Red | 12 | Light Red |
| 5 | Magenta | 13 | Light Magenta |
| 6 | Brown | 14 | Yellow |
| 7 | Light Gray | 15 | White |

**Attribute Calculation:**
```
attribute = (background * 16) + foreground
```

Examples:
- White on black: `07h` = (0 * 16) + 7
- Yellow on blue: `1Eh` = (1 * 16) + 14
- Blinking white on black: `87h` = 128 + 7

### ASCII Control Characters
| Hex | Dec | Name | Function |
|-----|-----|------|----------|
| 07h | 7 | BEL | Bell/Beep |
| 08h | 8 | BS | Backspace |
| 09h | 9 | TAB | Tab |
| 0Ah | 10 | LF | Line Feed |
| 0Dh | 13 | CR | Carriage Return |

---

## Tips and Best Practices

### 1. **Clearing the Screen**
The proper way to clear the screen:
```asm
mov ah, 06h       ; Scroll up
mov al, 00h       ; Clear entire window
mov bh, 07h       ; White on black
mov ch, 00h       ; Top-left (0,0)
mov cl, 00h
mov dh, 24        ; Bottom-right (24,79)
mov dl, 79
int 10h
```

### 2. **Cursor Management**
- Save cursor position before moving: 
  ```asm
  mov ah, 03h     ; Get position
  mov bh, 00h
  int 10h
  push dx         ; Save position
  
  ; ...  do work ...
  
  pop dx          ; Restore position
  mov ah, 02h
  mov bh, 00h
  int 10h
  ```

### 3. **Text vs Graphics Mode**
- **Text Mode (03h)**: Fast, easy, limited to characters
- **Graphics Mode (13h)**: Flexible, slower, pixel control

### 4. **Service Selection**
Choose the right service for your needs:
- **Sequential text**: Service 0Eh (teletype)
- **Positioned text**: Services 02h + 09h
- **Colored text**: Service 09h
- **Update text**: Service 0Ah
- **Graphics**: Service 0Ch (or direct memory for speed)

### 5. **Performance**
- BIOS services are convenient but slow
- For high-performance graphics, write directly to video memory
- Video memory in mode 13h:  segment A000h

### 6. **Common Mistakes**
- ❌ Forgetting to advance cursor after Service 09h/0Ah
- ❌ Using wrong attribute format
- ❌ Not checking screen boundaries
- ❌ Trying to use Service 0Ch in text mode

---

## Additional Resources

### Further Learning
- **BIOS Reference**:  Ralf Brown's Interrupt List
- **Assembly Tutorial**: Art of Assembly Language
- **DOS Programming**: DOS Programming Guide

### Related Topics
- Direct Video Memory Access
- VGA Hardware Programming
- Protected Mode Video
- Modern Graphics APIs

---

## About These Examples

These programs were created as educational resources for learning x86 assembly language and BIOS programming. Every line includes verbose comments explaining: 
- What the instruction does
- Why it's needed
- What values mean
- How it fits in the bigger picture

Perfect for students, hobbyists, and anyone interested in low-level programming! 

---

## License

These examples are provided for educational purposes.  Feel free to use, modify, and learn from them! 

---
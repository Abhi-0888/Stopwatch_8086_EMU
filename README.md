# 8086 Assembly language Stopwatch
---

# Stopwatch

This is a simple stopwatch program written completely in 8086 Assembly Language.
It runs in DOS or DOSBox and displays the time in a clean Minutes : Seconds : Hundredths format.
The purpose of this project was to build a fully working real-time stopwatch using only BIOS interrupts and basic text mode.

---

## Preview

```
==================================================
             8086 ASSEMBLY STOPWATCH              
==================================================
                STATUS: STOPPED

                  00:00:00

     [SPACE] Start/Stop   [R] Reset   [Q] Quit     
```

---

## Features

* Press **SPACE** to start or stop the stopwatch
* Press **R** to reset the timer to 00:00:00
* Press **Q** to quit the program
* Shows time in **MM:SS:HH** format
* Updates smoothly in real time
* Works entirely in text mode

---

## How It Works (Simple Explanation)

The program reads the computer's internal timer using a BIOS interrupt.
This timer increases several times per second, and by tracking those ticks, the stopwatch calculates the time that has passed.

The keyboard is checked continuously, so the stopwatch reacts immediately when a key is pressed.

---

## Controls

| Key   | Action                      |
| ----- | --------------------------- |
| SPACE | Start or stop the stopwatch |
| R     | Reset the time              |
| Q     | Exit the program            |

---

## How to Run

### Using MASM:

```
masm stopwatch.asm;
link stopwatch.obj;
stopwatch.exe
```

### Using TASM:

```
tasm stopwatch.asm
tlink stopwatch.obj
stopwatch.exe
```

### Using DOSBox:

```
STOPWATCH.EXE
```

---

## Why I Built This

I created this project to practice and understand:

* Using BIOS interrupts
* Reading and converting the system timer
* Detecting keyboard input
* Updating text-mode displays
* Writing structured code in 8086 assembly

Even though it is a small program, it teaches important low-level concepts.

---

## Project Files

```
sw.asm      - Main assembly source code
README.md   - Project documentation
```

---

## Future Improvements

Some things I might add later:

* More accurate timing
* Colored text for a better interface
* Support for longer running times
* A lap timing feature

---

## Like This Project?

If this project helped you or you enjoyed it, consider giving it a **star ⭐ on GitHub**!
It encourages me to do more work like this.

---


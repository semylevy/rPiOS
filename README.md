# rPiOS

A simple operating system for Raspberry Pi. Based on the Cambridge Course [Baking Pi](https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/).

Developed in ARM assembly. Supports Raspberry Pi 1 A.

## Features
Currently supports:
- Text
- Geometric shapes
- Keyboard input

## Usage
1. Use the provided makefile:
```
make
```
2. In an SD card with a Raspberry Pi OS installed, replace `kernel.img` with the generated `kernel.img`.
3. Power on RPi with SD card inserted.

#!/bin/bash

set -e
set -v

CC=gcc-4.6
CFLAGS="-m32 -fno-builtin -nostdinc -O2 -I. -Wall -Wno-error"
LDFLAGS="-m32 -nostdlib -Wl,-N -Wl,-Ttext -Wl,100000"
${CC} $CFLAGS -c keyboard.c
${CC} $CFLAGS -c delay.c
${CC} $CFLAGS -c common.c
${CC} $CFLAGS -c sound.c
${CC} $CFLAGS -c game.c
${CC} $CFLAGS -c kernel.c
${CC} $CFLAGS -c video.c
${CC} $CFLAGS -c memory.c
${CC} $CFLAGS -c boot.S
${CC} $LDFLAGS -o invaders.exec boot.o kernel.o keyboard.o video.o game.o sound.o delay.o common.o memory.o
# objcopy -O elf32-i386 invaders.exec invaders
objcopy -O binary invaders.exec invaders

CC = gcc
CFLAGS = -fno-stack-protector
TARGET = challenge
OBJS = challenge.o safe_printf.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

challenge.o: challenge.c safe_printf.h
	$(CC) $(CFLAGS) -c challenge.c

safe_printf.o: safe_printf.c
	$(CC) $(CFLAGS) -c safe_printf.c

clean:
	rm -f $(TARGET) $(OBJS)

.PHONY: all clean
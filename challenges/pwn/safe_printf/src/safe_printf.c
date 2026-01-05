#include <stdio.h>
#include <string.h>
#include <unistd.h>

void _printf(const char *text){
    int padding = 250;
    write(1, text, (padding+strlen(text)));
}
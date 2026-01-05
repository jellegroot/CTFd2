#include "safe_printf.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

struct minion {
  char name[20];
  int length;
  char dream[30];
};

void _() {
  FILE *f = fopen("./flag.txt", "r");
  if (f == NULL) {
    puts("Flag file not found!\n");
    return;
  }
  char flag[100];
  fread(flag, sizeof(flag), 1, f);
  fwrite(flag, sizeof(flag), 1, stdout);
  fclose(f);
}

void minion_dream(struct minion *m) {
  assert(m->length < 90);
  puts("\nWhats the dream of the minion: \n");
  fflush(stdout);
  fgets(m->name, m->length, stdin);
}

int minion_init(struct minion *m) {
  puts("Enter minion name: ");
  fflush(stdout);
  fgets(m->name, sizeof(m->name), stdin);
  int c;
  while ((c = getchar()) != '\n' && c != EOF);
  puts("Whats the length of your minion: ");
  fflush(stdout);
  scanf("%d", &m->length);
  while(getchar() != '\n'); 
  puts("Your minion is almost ready!\nDo you want to print previouse info about your minion? (y/n): ");
  fflush(stdout);
  char choice = getchar();
  while(getchar() != '\n'); 
  if (choice == 'y') {
    _printf(m->name);
  } 
  else {        
    puts("Goodbye!\n");
  }
  minion_dream(m);
  return 0;
}

int main() {
  setvbuf(stdin, NULL, _IONBF, 0);
  setvbuf(stdout, NULL, _IONBF, 0);
  setvbuf(stderr, NULL, _IONBF, 0);  
  puts("Lets start with your minion!\n");
  struct minion m;
  if(minion_init(&m) != 0) {
    puts("Error initializing minion!\n");
    return -1;
  }
  return 0;
}

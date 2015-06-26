#include "video.h"
#include "keyboard.h"
#include "sound.h"
#include "delay.h"

struct shot_t {
  int8 x,y; // x==-1 -> inactive shot
};
#define NUMSHOTS 5
static struct shot_t shots[NUMSHOTS];
static int8 ship,shipmove;

struct alien_t {
  int8 x,y; // x==-1 -> dead alien
  int8 xadd;
};
#define NUMALIENS 40
static struct alien_t aliens[NUMALIENS];

static bool gameover, winner;

void resetgame()
{
  gameover=false;
  winner=false;
  {
    uint8 i;
    for (i=0;i<NUMSHOTS;++i) shots[i].x=-1;
  };
  ship=40;
  shipmove=0;
  {
    uint8 x,y;
    for (x=0;x<8;++x) {
      for (y=0;y<5;++y) {
	struct alien_t *a = &aliens[y*8+x];
	a->x=x*7+12;
	a->y=y*2;
	a->xadd = ( (x%2) ^ (y%2) ) ? -1 : 1;
      };
    };
  };
};

void display()
{
  // clear screen
  video_usecolor(0,0);
  video_fill(0,0,80,25,0);

  // display shots
  {
    uint8 i;
    video_usecolor(4,0);
    for (i=0;i<NUMSHOTS;++i) {
      if (shots[i].x!=-1) {
	video_putchar(shots[i].x,shots[i].y,'|');
      };
    };
  };

  // display ship
  {
    video_usecolor(5,0);
    video_putchar(ship-1,24,'/');
    video_putchar(ship,23,'_');
    video_putchar(ship+1,24,'\\');
  };

  // display aliens
  {
    uint8 i;
    video_usecolor(3,0);
    for (i=0;i<NUMALIENS;++i) {
      if (aliens[i].x!=-1) {
	video_putchar(aliens[i].x-1,aliens[i].y,'-');
	video_putchar(aliens[i].x,aliens[i].y,'*');
	video_putchar(aliens[i].x+1,aliens[i].y,'-');
      };
    };
  };

  // show the picture
  video_update();
};

void keywork()
{
  uint8 key;
  bool pressed;
  for (;;) {
    key_decode(&key,&pressed);
    switch (key) {
    case '<':
      if (pressed) {
	shipmove=-1;
      }else{
	if (shipmove==-1) shipmove=0;
      };
      break;
    case '>':
      if (pressed) {
	shipmove=1;
      }else{
	if (shipmove==1) shipmove=0;
      };
      break;
    case ' ':
      {
	uint8 i;
	if (!pressed) break;
	for (i=0;i<NUMSHOTS;++i) {
	  if (shots[i].x==-1) {
	    shots[i].x=ship;
	    shots[i].y=24;
	    break;
	  };
	};
      };
      break;
    case 'x':
      return;
    };
  };
};

void calculate()
{
  uint8 i,k;
  bool foundalien=false;

  ship+=shipmove;
  if (ship<1) ship=1;
  if (ship>78) ship=78;

  for (i=0;i<NUMSHOTS;++i) {
    if (shots[i].x!=-1) {
      shots[i].y--;
	if (shots[i].y==-1) {
	  shots[i].x=-1;
	};
    };
  };
  for (i=0;i<NUMALIENS;++i) {
    if (aliens[i].x!=-1) {
      foundalien=true;
      for (k=0;k<NUMSHOTS;++k) {
	if (shots[k].x!=-1) {
	  if (shots[k].y==aliens[i].y) {
	    if ( (shots[k].x<=aliens[i].x+1) &&
		 (shots[k].x>=aliens[i].x-1) ) {
	      shots[k].x=-1;
	      aliens[i].x=-1;
	      goto nextalien;
	    };
	  };
	};
      };
      
      aliens[i].x += aliens[i].xadd;
      if (aliens[i].x<1) {
	aliens[i].x=1;
	aliens[i].xadd=1;
	aliens[i].y++;
      }else if (aliens[i].x>78) {
	aliens[i].x=78;
	aliens[i].xadd=-1;
	aliens[i].y++;
      };
      if (aliens[i].y>=20) gameover=true;
    };
  nextalien:;
  };

  if (!foundalien) gameover = winner = true;
};

void sounder()
{
  {
    uint8 i;
    for (i=0;i<NUMSHOTS;++i) {
      if (shots[i].x!=-1) {
	sound_freq(shots[i].y*100+100);
      }else{
	sound_nosound();
      };
      delay_wait(1193180/80);
    };
  };
  sound_nosound();
};

void displaygameover()
{
  uint8 key;
  bool pressed;

  video_usecolor(6,1);
  video_putstring(30,10,"  GAME OVER  ");
  video_putstring(30,11,winner ? "  YOU WIN  " : "  YOU LOOSE  ");
  video_putstring(30,12,"  PRESS ESC  ");
  video_update();
  do{
    key_decode(&key,&pressed);
    key_polling(); 
  } while (!(pressed&&(key=='@')));
};

void game()
{
  //   video_blinkchars(false);
  video_hidecursor();

  for (;;) {
    resetgame();

    while (!gameover) {
      display();
      sounder();
      keywork();
      calculate();
    };

    displaygameover();
  };
};

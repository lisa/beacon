#include <Wire.h>
#include <EEPROM.h>
#include <avr/wdt.h>

#define WDT_TIMEOUT 9  // ~8 seconds
#define MAX_I2C_RETRIES 10
#define RANDOM_COLOUR (byte)random(1,8)
#define RANDOM_BOARD (byte)random(0,5)
#define RANDOM_LED (byte)random(0,10)
#define RANDOM_PROGRAM (byte)random(0,9)
#define RANDOM_RUNS (int)random(200,300)
#define RANDOM_RUN_DELAY (int)random(100,200)
#define RANDOM_BOOL (bool)random(0, 2)

#define PROGRAM1_DELAY 100

#define RANDOMSEED_EEPROM_LOC 0x5

// #define DO_TESTPROGRAM
#define PROGRAMTEST_DELAY 1000

#define LAYER1_ADDR 0x01
#define LAYER2_ADDR 0x02
#define LAYER3_ADDR 0x03
#define LAYER4_ADDR 0x04

#define DARK   0x00
#define RED    0x01
#define GREEN  0x02
#define YELLOW 0x03
#define BLUE   0x04
#define PURPLE 0x05
#define TEAL   0x06
#define WHITE  0x07

#define L0R 31
#define L0G 30
#define L0B 29
#define L1R 28
#define L1G 27
#define L1B 26
#define L2R 25
#define L2G 24
#define L2B 0 
#define L3R 1
#define L3G 2
#define L3B 3
#define L4R 4
#define L4G 5
#define L4B 6
#define L5R 7
#define L5G 18
#define L5B 19
#define L6R 20
#define L6G 21
#define L6B 22
#define L7R 23
#define L7G 8
#define L7B 9
#define L8R 10
#define L8G 11
#define L8B 12
#define L9R 13
#define L9G 14
#define L9B 15


struct led {
  byte r_pin_addr;       /* Layer-local pin address */
  byte g_pin_addr;       /* Layer-local pin address */
  byte b_pin_addr;       /* Layer-local pin address */
  byte colour;  /* Colour status of this LED */
};

struct layer {
  byte i2c_addr;       /* i2c bus address; NULL = master board */
  struct led leds[10]; /* all LEDs on this board */
};


byte colours[] = { DARK, RED, GREEN, YELLOW, BLUE, PURPLE, TEAL, WHITE };
enum program_state { PROG_INIT, PROG_ADVANCE, PROG_DELAY };
enum loop_state { LOOP_INIT, LOOP_GO };
struct layer layer[5];
loop_state loopstate;
  
void setup() {
  wdt_disable();
  wdt_enable(WDT_TIMEOUT);
  wdt_reset();
  int i;

  set_random();
  for (i = 0; i <= 31; i++)
    pinMode(i,OUTPUT);

  layer[0].i2c_addr = NULL; /* master is NULL */
  layer[0].leds[0].r_pin_addr = L0R;  layer[0].leds[0].g_pin_addr = L0G;
  layer[0].leds[0].b_pin_addr = L0B;  layer[0].leds[0].colour = DARK;

  layer[0].leds[1].r_pin_addr = L1R;  layer[0].leds[1].g_pin_addr = L1G;
  layer[0].leds[1].b_pin_addr = L1B;  layer[0].leds[1].colour = DARK;

  layer[0].leds[2].r_pin_addr = L2R;  layer[0].leds[2].g_pin_addr = L2G;
  layer[0].leds[2].b_pin_addr = L2B;  layer[0].leds[2].colour = DARK;

  layer[0].leds[3].r_pin_addr = L3R;  layer[0].leds[3].g_pin_addr = L3G;
  layer[0].leds[3].b_pin_addr = L3B;  layer[0].leds[3].colour = DARK;

  layer[0].leds[4].r_pin_addr = L4R;  layer[0].leds[4].g_pin_addr = L4G;
  layer[0].leds[4].b_pin_addr = L4B;  layer[0].leds[4].colour = DARK;

  layer[0].leds[5].r_pin_addr = L5R;  layer[0].leds[5].g_pin_addr = L5G;
  layer[0].leds[5].b_pin_addr = L5B;  layer[0].leds[5].colour = DARK;

  layer[0].leds[6].r_pin_addr = L6R;  layer[0].leds[6].g_pin_addr = L6G;
  layer[0].leds[6].b_pin_addr = L6B;  layer[0].leds[6].colour = DARK;

  layer[0].leds[7].r_pin_addr = L7R;  layer[0].leds[7].g_pin_addr = L7G;
  layer[0].leds[7].b_pin_addr = L7B;  layer[0].leds[7].colour = DARK;

  layer[0].leds[8].r_pin_addr = L8R;  layer[0].leds[8].g_pin_addr = L8G;
  layer[0].leds[8].b_pin_addr = L8B;  layer[0].leds[8].colour = DARK;
  
  layer[0].leds[9].r_pin_addr = L9R;  layer[0].leds[9].g_pin_addr = L9G;
  layer[0].leds[9].b_pin_addr = L9B;  layer[0].leds[9].colour = DARK;
  
  for (i = 1; i <= 4; i++)
    layer[i].i2c_addr = i;
    
  loopstate = LOOP_INIT;
  wdt_reset();
  // disable the TWI module in case it's still hung up somehow from before a reset
  TWCR = 0;
  Wire.begin();
  
#ifdef DO_TESTPROGRAM
  programtest(1,layer);
#endif
}


void loop() {
  switch (loopstate) {
    
    case LOOP_INIT:
    turn_off_all_leds(layer);
    loopstate = LOOP_GO;
    break;
    
    case LOOP_GO:
    switch (RANDOM_PROGRAM) {
      case 0:
      for (int i = 0; i < 30; i++) {
        wdt_reset();
        delay(1000);
      }
      break;
      case 1:
      program1(RANDOM_RUNS, PROGRAM1_DELAY, layer);
      break;
      case 2:
      program2(RANDOM_RUNS, RANDOM_RUN_DELAY, layer);
      break;
      case 3:
      program3(RANDOM_RUNS, RANDOM_RUN_DELAY, layer);
      break;
      case 4:
      program4(RANDOM_RUNS, RANDOM_RUN_DELAY, layer);
      break;
      case 5:
      program5(RANDOM_RUNS, RANDOM_RUN_DELAY, layer);
      break;
      case 6:
      program6(RANDOM_RUNS, RANDOM_RUN_DELAY, layer);
      break;
      case 7:
      program7(RANDOM_RUNS, RANDOM_RUN_DELAY, layer);
      break;
      case 8:
      program8(RANDOM_RUNS, RANDOM_RUN_DELAY >> 1, layer);
      break;
    }
    
    turn_off_all_leds(layer);
    delay(RANDOM_RUN_DELAY * 5);
    loopstate = LOOP_GO;
    break;    
  }  
}

inline void set_random() {
  randomSeed(EEPROM.read(RANDOMSEED_EEPROM_LOC));
  EEPROM.write(RANDOMSEED_EEPROM_LOC,random(255));
  return;  
}

inline void set_led_status(struct layer layer, const byte led_idx, const byte colour) {
  int retried = 0;
  layer.leds[led_idx].colour = colour;
  if (layer.i2c_addr == NULL) {
    /* on master layer */
    digitalWrite(layer.leds[led_idx].r_pin_addr,( layer.leds[led_idx].colour & RED)   == RED   );
    digitalWrite(layer.leds[led_idx].g_pin_addr,( layer.leds[led_idx].colour & GREEN) == GREEN );
    digitalWrite(layer.leds[led_idx].b_pin_addr,( layer.leds[led_idx].colour & BLUE)  == BLUE  );
  }
  else {
    /* on slave layer */
    do {
      Wire.beginTransmission(layer.i2c_addr);
      Wire.send(led_idx);
      Wire.send(layer.leds[led_idx].colour); /* other end needs to decode as above */
    } while (Wire.endTransmission() > 0 && retried++ < MAX_I2C_RETRIES);
  }
  return;
}

inline void fade_mode(const bool on) {
  int retried = 0;
  for(byte layernbr=1; layernbr<5; layernbr++) {
    retried = 0;
    do {
      Wire.beginTransmission(layer[layernbr].i2c_addr);
      Wire.send(0);
      Wire.send((on ? 128 : 64)); /* 128 turns on fade mode, 64 turns it off */
    } while (retried++ < MAX_I2C_RETRIES && Wire.endTransmission() > 0);
  }
}


inline void turn_off_all_leds(struct layer layer[]) {
   byte i, j;
  for (i = 0; i < 5; i++) {
    for (j = 0; j < 10; j++) {
      wdt_reset();
      set_led_status(layer[i],j,DARK);
      delay(2);
    }
  }
}

inline byte random_primary() {
  switch (random(0,3)) {
    case 0:
    return RED;
    break;
    case 1:
    return GREEN;
    break;
    case 2:
    return BLUE;
    break;
  }  
}

void programtest( const int runs, struct layer layer[]) {
   byte i, j, c;
  turn_off_all_leds(layer);
  for (i = 0; i < 5; i++) {
    for (j = 0; j < 10; j++) {
      wdt_reset();
      /* Turning on WHITE turns on all LEDs */
      set_led_status(layer[i],j,WHITE); 
      delay(PROGRAMTEST_DELAY);
      set_led_status(layer[i],j,DARK);
      delay(PROGRAMTEST_DELAY);
    }
  }
}


/* Program 1:
 * (5 on) Offset LEDs in each layer rotate around the axis with random colour choice for each vertical frame:
 * x    x    x    x    x    x    x    x    x
 *  x    x    x    x    x    x    x    x    x
 *   x    x    x    x    x    x    x    x    x
 *    x    x    x    x    x    x    x    x    x
 *     x    x    x    x    x    x    x    x    x
**/
void program1( const int runs,  const int round_delay, struct layer layer[]) {
  int runcount = 0;
  program_state state = PROG_INIT;
  int j;
  int start_idx = 0;
  byte colour = RANDOM_COLOUR;
  while ( runcount++ < runs) {
    switch (state) {
      case PROG_INIT:
      for (j = 0; j < 5; j++)
        set_led_status(layer[j],start_idx + j,colour);
      state = PROG_ADVANCE;
      break;
      
      case PROG_ADVANCE:
      wdt_reset();
      colour = RANDOM_COLOUR;
      for (j = 0; j < 5; j++ ) {
        set_led_status(layer[j], (start_idx + j) % 10, DARK);
      }
      
      start_idx = (start_idx + 1) % 10;
      for (j = 0; j < 5; j++ ) {
        set_led_status(layer[j], (start_idx + j) % 10, colour);
      }
            
      
      state = PROG_DELAY;
      break;
      case PROG_DELAY:
      delay(round_delay);
      state = PROG_ADVANCE;
      break;
    }
  }
  return;
}


/* (1 on): Quick flashes of individual random LEDs in random colours. */
void program2( const int runs,  const int round_delay, struct layer layer[]) {
  program_state state = PROG_ADVANCE;
   int runcount = 0;
   byte last_board_idx = 0, last_led_idx = 0;
  while (runcount++ < runs) {
    switch (state) {
      case PROG_ADVANCE:
      wdt_reset();
      set_led_status(layer[last_board_idx], last_led_idx, DARK);
      last_led_idx = RANDOM_LED;
      last_board_idx = RANDOM_BOARD;
      set_led_status(layer[last_board_idx],last_led_idx,RANDOM_COLOUR);
      state = PROG_DELAY;
      break;
      
      case PROG_DELAY:
      delay(round_delay);
      state = PROG_ADVANCE;
      break;
    }    
  }
  
  return;
}


/* (5 on): Vertical columns of LEDs rotating around the axis with random colour for each frame */
void program3(const int runs,  const int round_delay, struct layer layer[]) {
  program_state state = PROG_ADVANCE;
   int runcount = 0;
   byte i = 0, colour;
  
  while (runcount < runs) {
    switch (state) {
      case PROG_ADVANCE:
      wdt_reset();
      colour = RANDOM_COLOUR;
      for (i = 0; i < 5; i++) {
        set_led_status(layer[i],((runcount - 1) % 10), DARK);
        set_led_status(layer[i],runcount % 10, colour);
      }
      state = PROG_DELAY;
      runcount += 1;
      break;
      case PROG_DELAY:
      delay(round_delay);
      state = PROG_ADVANCE;
      break;
    }
  } 
}

/* (5 on): Vertical columns of LEDs rotating around the axis with random colour for each LED of each frame */
void program4(const int runs, const int round_delay, struct layer layer[]) {
  program_state state = PROG_ADVANCE;
   int runcount = 0;
   byte i = 0, j = 0, last_board_idx = 0, colour = DARK;
  
  while (runcount < runs) {
    switch (state) {
      case PROG_ADVANCE:
      wdt_reset();
      for (i = 0; i < 5; i++) {
        set_led_status(layer[i],((runcount - 1) % 10), DARK);
        set_led_status(layer[i],runcount % 10, RANDOM_COLOUR);
      }
      runcount += 1;
      state = PROG_DELAY;
      break;
      case PROG_DELAY:
      delay(round_delay);
      state = PROG_ADVANCE;
      break;
    }
  } 
}

/* (9 on): "Cop Mode" - LEDs 2, 3, 4 and 7, 8, 9 of  Layers 1, 2 and 3 
 * alternate red and blue in groups (3-5, then 0,9,8). There will be one side
 * on at any given time.
**/
void program5(const int runs, const int round_delay, struct layer layer[]) {
  program_state state = PROG_INIT;
  int runcount = 0;
  byte i;
  while (runcount < runs) {
    switch (state) {
      case PROG_INIT:
      for (i = 1; i < 4; i++) {
        set_led_status(layer[i],2,RED);
        set_led_status(layer[i],3,RED);
        set_led_status(layer[i],4,RED);
      }
      state = PROG_ADVANCE;
      runcount += 1;
      break;
      
      case PROG_ADVANCE:
      wdt_reset();
      for (i = 1; i < 4; i++) {
        if (runcount % 2 == 0) {
          set_led_status(layer[i], 7, DARK);
          set_led_status(layer[i], 8, DARK);
          set_led_status(layer[i], 9, DARK);
          set_led_status(layer[i], 2, RED);
          set_led_status(layer[i], 3, RED);
          set_led_status(layer[i], 4, RED);
        }
        else {
          set_led_status(layer[i], 7, BLUE);
          set_led_status(layer[i], 8, BLUE);
          set_led_status(layer[i], 9, BLUE);
          set_led_status(layer[i], 2, DARK);
          set_led_status(layer[i], 3, DARK);
          set_led_status(layer[i], 4, DARK);
        }
      }
      runcount += 1;
      state = PROG_DELAY;
      break;
      
      case PROG_DELAY:
      delay(round_delay);
      state = PROG_ADVANCE;
      break;
    }
  }  
}

/* (10 on): Illuminate each row and oscillate up and down the vertical axis 
 * with a random colour for each up movement and a sepratate random colour
 * for each down movement. Primary colours only; use random_primary().
 * Since this is an expensive program we bias the number of runs in half.
 * TODO: Clean this up!
**/
void program6(const int runs, const int round_delay, struct layer layer[]) {
  program_state state = PROG_INIT;
  byte colour, cur_layer;
  int runcount = 0, j;
  bool going_up = true;
  while (runcount < (runs >> 1)) {
    switch (state) {
      case PROG_INIT:
      going_up = true;
      cur_layer = 0;
      colour = random_primary();
      for (j = 0; j < 10; j++) {
       set_led_status(layer[cur_layer],j,colour);
      }
      state = PROG_DELAY;
      runcount += 1;
      break;
      
      case PROG_ADVANCE:
      wdt_reset();
      /*
      When going up:
       When the current layer is 4 turn around:
        * going_up = false
        * turn off layer 4
        * turn on layer 3
        * cur_layer = 3
       When the current layer is < 4 then:
        * turn off current layer
        * turn on layer + 1
        * increment cur_layer
      When going down:
       When the current layer is 0 turn around:
        * going_up = true
        * turn off layer 0
        * turn on layer 1
        * cur_layer = 1
       When the current layer > 0 then:
        * turn off current layer
        * turn on layer - 1
        * decrement cur_layer         
      */    
      /* ********************************** */
      if (going_up) {
        if (cur_layer == 4) {
          colour = random_primary();
          going_up = false;
          for (j = 0; j < 10; j++) {
            set_led_status(layer[4], j, DARK);
            set_led_status(layer[3], j, colour);
          }
          cur_layer = 3;
        }
        else {
          for (j = 0; j < 10; j++) {
            set_led_status(layer[cur_layer], j, DARK);
            set_led_status(layer[cur_layer + 1], j, colour);
          }
          cur_layer += 1;
        } /* cur_layer < 4 */  
      } /* if going_up */
      else {
        if (cur_layer == 0) {
          colour = random_primary();
          going_up = true;
          for (j = 0; j < 10; j++) {
            set_led_status(layer[cur_layer], j, DARK);
            set_led_status(layer[1], j, colour);
          }
          cur_layer = 1;
        }
        else {
          for (j = 0; j < 10; j++) {
            set_led_status(layer[cur_layer], j, DARK);
            set_led_status(layer[cur_layer - 1], j, colour);
          }
          cur_layer -= 1;
        } /* cur_layer > 0 */ 
      } /* else going down */
      state = PROG_DELAY;
      runcount += 1;
      break;
      
      case PROG_DELAY:
      delay(round_delay);
      state = PROG_ADVANCE;
      break;
    }    
  }  
}

/* (2 on) One LED chases another around the board */
void program7(const int runs, const int round_delay, struct layer layer[]) {
  program_state state = PROG_INIT;
  byte leader_colour = RANDOM_COLOUR, chaser_colour = RANDOM_COLOUR;
  byte leader_led = 4, chaser_led = 1;
  int runcount = 0;
  while (runcount < runs) {
    switch (state) {
      case PROG_INIT:
      set_led_status(layer[0],leader_led,leader_colour);
      set_led_status(layer[0],chaser_led,chaser_colour);
      state = PROG_DELAY;
      runcount += 1;
      break;
      
      case PROG_ADVANCE:
      wdt_reset();
      set_led_status(layer[0],leader_led,DARK);
      leader_led = (leader_led + 1) % 10;
      set_led_status(layer[0],leader_led,leader_colour);
      set_led_status(layer[0],chaser_led,DARK);
      chaser_led = (chaser_led + 1) % 10;
      set_led_status(layer[0],chaser_led,chaser_colour);
      state = PROG_DELAY;
      runcount += 1;
      break;
      
      
      case PROG_DELAY:
      delay(100);
      state = PROG_ADVANCE;
      break;
    } 
  }
}

/* (3 on): Illuminate one LED in each primary colour colour, then choose a 
   direction for each LED to movand move the lit LED there.  Repeat.
*/
void program8(const int runs, const int round_delay, struct layer layer[]) {
  struct single_led {
    byte layer;
    byte led;
    byte colour;
  };
  
  struct single_led lit_led[3];
  lit_led[0].layer = 2;
  lit_led[0].led = 0;
  lit_led[0].colour = RED;
  lit_led[1].layer = 2;
  lit_led[1].led = 0;
  lit_led[1].colour = GREEN;
  lit_led[2].layer = 2;
  lit_led[2].led = 0;
  lit_led[2].colour = BLUE;
  
  for(int runcount=0; runcount<runs; runcount++) {
    wdt_reset();
    for(byte i=0; i<3; i++) {
      delay(round_delay);

      // figure out what colour this specific pixel should be once our led is shut off and set it
      byte mixed_colour = DARK;
      for(byte other_leds=0; other_leds < 3; other_leds++) {
        if(other_leds == i) continue;
        if(lit_led[other_leds].layer == lit_led[i].layer && lit_led[other_leds].led == lit_led[i].led)
          mixed_colour |= lit_led[other_leds].colour;
      }
      set_led_status(layer[lit_led[i].layer], lit_led[i].led, mixed_colour);
      
      // figure out a random direction and move our led to that pixel
      lit_led[i].layer += random(-1, 2);
      lit_led[i].led += random(-1, 2);
      if(lit_led[i].led < 0) lit_led[i].led = 9;
      if(lit_led[i].led > 9) lit_led[i].led = 0;
      if(lit_led[i].layer < 0) lit_led[i].layer = 4;
      if(lit_led[i].layer > 4) lit_led[i].layer = 0;
      
      // mix in the colours of any other leds that are sharing this specific pixel with us right now and set it
      mixed_colour = lit_led[i].colour;
      for(byte other_leds=0; other_leds < 3; other_leds++) {
        if(lit_led[other_leds].layer == lit_led[i].layer && lit_led[other_leds].led == lit_led[i].led)
          mixed_colour |= lit_led[other_leds].colour;
      }
      set_led_status(layer[lit_led[i].layer], lit_led[i].led, mixed_colour);
    }
  }
}
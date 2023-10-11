#include <graphics.h>
#include <iostream>
#include<conio.h>
#include <vector>

//Not include: libstdc++-6.dll |  libgcc_s_dw2-1.dll
using namespace std;
class Snake{
private:
      int x;
      int y;
public:
      Snake(){}

      void move(int x,int y){
            this->x=x;
            this->y=y;
      }
      int getX(){return x;}
      int getY(){return y;}

};

int GetRandom(int min,int max){
    return min + (int)(rand()*(max-min+1.0)/(1.0+RAND_MAX));
}
string Type_Move(int type){
      if(type == 97 || type == 65){
            return "Left";
      }
      if(type == 119 || type == 87){
            return "Up";
      }
      if(type == 100 || type == 68){
            return "Right";
      }
      if(type == 115 || type == 83){
            return "Down";
      }
return "None";
}

void Move(int speed,int gm,int gd,int &x, int &y, string move){
      if(move == "Right"){
            x = x+speed;
      circle(x,y,5);
      }
      if(move == "Down"){    
            y = y+speed; 
      circle(x,y,5);
      }
      if(move == "Up"){
            y = y-speed;
       circle(x,y,5);     
      }
       if(move == "Left"){
            x = x-speed;
      circle(x,y,5);
      }
}


void Snake_Move(int gm,int gd,int &x,int &y, string move,int speed ){

      Move(speed,gm,gd,x,y,move);
      if(x >= gd || x <= 0){
      if(x >= gd){x = 0;}
      else{x = gd;}
      }
   if(y >= gm || y <= 0){ 
      if(y >= gm){y = 0;}
      else{y = gm;}
     }
}

void Make_Apple(int &a,int &b){
circle(a,b,8);
line(a-8,b-8,a+8,b+8);
}

bool Eat_Apple(int x,int y,int a,int b){
if((x-10 <= a+8 && x+10 >= a-8)&&(y-10 <= b+8 && y+10 >= b-8)){
      return true;
}
return false;
}


void Running_Car(){
for (int i = 0; i <= 1600; i = i + 10) {
 
        // Set color of car as red
        setcolor(RED);
 
        // These lines for bonnet and
        // body of car
        line(0 + i, 300, 210 + i, 300);
        line(50 + i, 300, 75 + i, 270);
        line(75 + i, 270, 150 + i, 270);
        line(150 + i, 270, 165 + i, 300);
        line(0 + i, 300, 0 + i, 330);
        line(210 + i, 300, 210 + i, 330);
 
        // For left wheel of car
        circle(65 + i, 330, 15);
        circle(65 + i, 330, 2);
 
        // For right wheel of car
        circle(145 + i, 330, 15);
        circle(145 + i, 330, 2);
 
        // Line left of left wheel
        line(0 + i, 330, 50 + i, 330);
 
        // Line middle of both wheel
        line(80 + i, 330, 130 + i, 330);
 
        // Line right of right wheel
        line(210 + i, 330, 160 + i, 330);
 
        delay(100);
 
        // To erase previous drawn car
        // use cleardevice() function
        cleardevice();
    }
}

bool Control(string move,string last_move){
      if(move == "Up"&& last_move == "Down") {return false;} 
      if(move == "Down" && last_move == "Up"){ return false;}
      if(move == "Left" && last_move == "Right"){return false;}
      if(move == "Right" && last_move == "Left"){return false; }
      return true;
}
void Num(int x,int y){
circle(x,y,5);
}

 main(){
      int speed = 10;
  char key_press;
  int ascii_value;
  int pos_x = GetRandom(10,1600),pos_y= GetRandom(10,800);
  int lose = 50;
  string move = "Left";
  string last_move;
  int num_body = 4;
  bool done = true;
      const string text = to_string(num_body);
  int gd=1600, gm = 800;
      initwindow(gd,gm);
    setbkcolor(0);
     cleardevice();
vector<Snake> snake;
snake.resize(num_body);
for (int i = 0;i<num_body;i++){
      snake[i].move(lose,10);
      Num(snake[i].getX(),snake[i].getY());
      lose+=10;
}
vector<int> x  ,y;
x.resize(num_body);
y.resize(num_body);
x[0] = snake[0].getX();
y[0] = snake[0].getY();
int new_x,new_y; 
int a = x[0], b = y[0];
Make_Apple(pos_x,pos_y);
delay(1000);
Snake_Move(gm,gd,x[0],y[0],move,speed);


while(done == true){
      char buffer[100];
      sprintf(buffer, "%d", num_body);
    outtext("Score: ")  ;
   outtext(buffer);
 //  outtext(char(text));
 if(Eat_Apple(x[0],y[0],pos_x,pos_y) || ascii_value == 32){
     num_body++; 
     snake.resize(num_body);
     x.resize(num_body);
     y.resize(num_body);
      snake[num_body-1].move(new_x,new_y);
      Num(new_x,new_y);
      pos_x = GetRandom(10,1600);pos_y= GetRandom(10,800);
      Make_Apple(pos_x,pos_y);
      speed+=1;
 }     
for (int i =1; i<num_body;i++){
      snake[i].move(a,b);
      a = x[i]; b = y[i];
      x[i] = snake[i].getX();
      y[i] = snake[i].getY();  
       Num(x[i],y[i]);
       if(x[0] == x[i] && y[0] == y[i]){
            done = false;
            break;
       }
      }
       if(kbhit()==true){
      key_press=getch();
       ascii_value=key_press;
       last_move = move;
       move = Type_Move(ascii_value);
       if(!Control(move,last_move)){
            move = last_move;
       }
       }

       delay(100);
    cleardevice();
     Make_Apple(pos_x,pos_y);
    new_x = x[num_body-1];
    new_y = y[num_body-1];
    a = x[0]; b = y[0];
    
Snake_Move(gm,gd,x[0],y[0],move,speed);
}
 setbkcolor(3);
     cleardevice();
     moveto(800,400);
    outtext("You lose");
     getch();
}

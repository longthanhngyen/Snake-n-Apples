#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Blue  // up[]
#property indicator_color2 Red   // down[]
#property indicator_color3 Red   // channel[]
#property indicator_color4 Blue  // channel[]
#property indicator_color5 Blue  // arrup[]
#property indicator_color6 Red   // arrdwn[]
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 5
#property indicator_width6 5

 ENUM_TIMEFRAMES TimeFrame  = PERIOD_M1;
extern int    Amplitude           = 2.0;
extern double ChannelDeviation    = 2;
 bool   alertsOn            = false;
 bool   alertsOnCurrent     = false;
 bool   alertsMessage       = false;
 bool   alertsSound         = false;
 bool   alertsEmail         = false;
 bool   alertsNotify        = false;
 bool   ShowChannels        = false;
 bool   ShowArrows          = true;
 bool   ArrowsOnFirstBar    = true;

double up[],down[],atrlo[],atrhi[],trend[];
double arrup[],arrdwn[], atr[];

string indicatorFileName;
bool   returnBars;
double atr2;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
  {
   for (int i=0; i<indicator_buffers; i++) 
   
   SetIndexStyle(i,DRAW_LINE);
   IndicatorBuffers(8);
   SetIndexBuffer(0,up);
   SetIndexBuffer(1,down);
   SetIndexBuffer(2,atrlo);
   SetIndexBuffer(3,atrhi);
   SetIndexBuffer(4,arrup);
   SetIndexBuffer(5,arrdwn);
   SetIndexBuffer(6,trend);
   SetIndexBuffer(7,atr);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(6,0.0);
   SetIndexEmptyValue(7,0.0);
   
   if(ShowChannels)
   {
      SetIndexStyle(2,DRAW_LINE, STYLE_DOT);
      SetIndexStyle(3,DRAW_LINE, STYLE_DOT);
   }
   else
   {
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
   }
   if (ShowArrows)
   {
     SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID); SetIndexArrow(4,233);
     SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID); SetIndexArrow(5,234);   
   }
   else
   {
     SetIndexStyle(4,DRAW_NONE);
     SetIndexStyle(5,DRAW_NONE);
   }        
     
   indicatorFileName = WindowExpertName();
   returnBars        = TimeFrame == -99;
   TimeFrame         = MathMax(TimeFrame,_Period);
   string short_name="Half trend MTF (" + DoubleToStr(Amplitude,0) + ")       Time Frame= "+TimeFrame+" min";
   IndicatorShortName(short_name);
return (0);
  }

class CFix { } ExtFix;

int start()
{  int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { up[0] = limit+1; return(0); }
            if (TimeFrame!=Period())
            {
               int shift = -1; if (ArrowsOnFirstBar) shift=1;
               limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
               for (int i=limit; i>=0; i--)
               {
                   int y = iBarShift(NULL,TimeFrame,Time[i]);  
                   int x = iBarShift(NULL,TimeFrame,Time[i+shift]);             
                      up[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_M1,Amplitude,ChannelDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsEmail,alertsNotify,0,y);  //alertsSound,           
                      down[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_M1,Amplitude,ChannelDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsEmail,alertsNotify,1,y);  //alertsSound,
                      atrlo[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_M1,Amplitude,ChannelDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsEmail,alertsNotify,2,y);  //alertsSound,         
                      atrhi[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_M1,Amplitude,ChannelDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsEmail,alertsNotify,3,y);  //alertsSound,
                   if(x!=y)
                   {
                     arrup[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_M1,Amplitude,ChannelDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsEmail,alertsNotify,4,y);   //alertsSound,          
                     arrdwn[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_M1,Amplitude,ChannelDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsEmail,alertsNotify,5,y);   //alertsSound,
                              
                   }
                   else
                   {
                     arrup[i]  = EMPTY_VALUE;
                     arrdwn[i] = EMPTY_VALUE;
                   }
               }
               return(0);
            }
   double lowprice_i,highprice_i,lowma,highma;
   int workbar=0;
   double nexttrend=0,maxlowprice=Low[Bars-1],minhighprice=High[Bars-1];
   for(i=Bars-1; i>=0; i--)
     {
      lowprice_i  = iLow(NULL,0,iLowest(NULL,0,MODE_LOW,Amplitude,i));
      highprice_i = iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,Amplitude,i));
      lowma       = NormalizeDouble(iMA(NULL,0,Amplitude,0,MODE_SMA,PRICE_LOW,i),Digits());
      highma      = NormalizeDouble(iMA(NULL,0,Amplitude,0,MODE_SMA,PRICE_HIGH,i),Digits());
      trend[i]=trend[i+1];
      arrup[i]  = EMPTY_VALUE;
      arrdwn[i] = EMPTY_VALUE;
           
      atr2=iATR(NULL,0,100,i)/2;
                  
      if(nexttrend==1)
        {
         maxlowprice=MathMax(lowprice_i,maxlowprice);

         if(highma<maxlowprice && Close[i]<Low[i+1])
           {
            trend[i]=1.0;
            nexttrend=0;
            minhighprice=highprice_i;
           }
        }
      if(nexttrend==0)
        {
         minhighprice=MathMin(highprice_i,minhighprice);

         if(lowma>minhighprice && Close[i]>High[i+1])
           {
            trend[i]=0.0;
            nexttrend=1;
            maxlowprice=lowprice_i;
           }
        }
      if(trend[i]==0.0)
        {
         if(trend[i+1]!=0.0)
           {
            up[i]=down[i+1];
            up[i+1]=up[i];
            arrup[i] = up[i] - atr2;/// posicion flecha up
           }
         else
           {
            up[i]=MathMax(maxlowprice,up[i+1]);
           }
         atrhi[i] = up[i] - ChannelDeviation*atr2;
         atrlo[i] = up[i] + ChannelDeviation*atr2;
         down[i]=0.0;
        }
      else
        {
         if(trend[i+1]!=1.0)
           {
            down[i]=up[i+1];
            down[i+1]=down[i];
            arrdwn[i] = down[i] + atr2;/// posicion flecha down
           }
         else
           {
            down[i]=MathMin(minhighprice,down[i+1]);
           }
         atrhi[i] = down[i] - ChannelDeviation*atr2;
         atrlo[i] = down[i] + ChannelDeviation*atr2;
         up[i]=0.0;
        }
     }
     manageAlerts();
   return (0);
  }
  
//-------------------------------------------------------------------

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//+-------------------------------------------------------------------

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 
         if (arrup[whichBar]  != EMPTY_VALUE) doAlert(whichBar,"BUY");
         if (arrdwn[whichBar] != EMPTY_VALUE) doAlert(whichBar,"SELL");
   }
}

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       message = "HalfTrend: "+doWhat+" "+Symbol()+ " TF "+Period()+ " min at " +   DoubleToStr(Close[0],Digits);
       //message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," HalfTrend ",doWhat);
          if (alertsMessage)      Alert(message);
          if (alertsEmail)        SendMail(StringConcatenate(Symbol(),"HalfTrend "),message);
          //if (alertsSound)        PlaySound("alert3.wav");
          //if (alertsNotify)       SendNotification(message);
   }
}
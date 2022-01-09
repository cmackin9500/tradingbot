double upper(int position)
// gets the value of position th upper fractal from the right (counting from 0)
{
   double ufrac = 0;
   int count  = 0;
   
   for(int i = 0;; i++)
   {
      ufrac = iFractals(_Symbol,PERIOD_M5,MODE_UPPER,i);
      if (ufrac != 0)
         {
            if(count == position) 
            {
               return ufrac;
            }
            else
            {
               count++;
               continue;
            }
         }
      else 
         {continue;}
   }
}

double lower(int position)
// get the value of the low of the position th position from the right
{
   double lfrac = 0;
   int count  = 0;
   for(int i = 0; ; i++)
   {
      lfrac = iFractals(_Symbol,PERIOD_M5,MODE_LOWER,i);
      if (lfrac != 0)
         {
            if(count == position) 
            {
               return lfrac;
            }
            else
            {
               count++;
               continue;
            }
         }
      else 
         {continue;}
   }
}
  
bool BullStoch(int i)
// Stochastic cross under 50
{
   double prevStoch = iStochastic(_Symbol,PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,i);
   double Stoch = iStochastic(_Symbol,PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,i-1);
   if (Stoch < 50 && prevStoch >= 50) 
   {
      return true;
   }
   else 
   {
      return false;
   }
}

int posUpper(int x)
// gets the candle number of specified upper fractal
{
   double ufrac = 0;
   int count = 0;
   for(int i = 0; ; i++)
   {
      ufrac = iFractals(_Symbol,PERIOD_M5,MODE_UPPER,i);
      if(ufrac !=0) 
      {
         if(x == count)
         {
            return i;
         }
         else 
         {
            count++;
            continue;
         }
      }
      else
      {
         continue;
      }
   }
}

int posLower(int x)
// gets the candle number of specified lower fractal
{
   double lfrac = 0;
   int count = 0;
   for(int i = 0; ; i++)
   {
      lfrac = iFractals(_Symbol,PERIOD_M5,MODE_LOWER,i);
      if(lfrac !=0) 
      {
         if(x == count)
         {
            return i;
         }
         else 
         {
            count++;
            continue;
         }
      }
      else
      {
         continue;
      }
   }
}

bool fiveque()
// returns true if the 5 min que is true
{
//   if(upper(0) < upper(1)) 
//   {
//      return false;
//   }
   
   bool pos = false;
   for(int i = posUpper(1); i > posUpper(0); i--)
   {
      if(iHigh(_Symbol,PERIOD_M5,posUpper(1)) < iClose(_Symbol,PERIOD_M5,i))
      {
         pos = true;
      }
   }
   
   bool stoch = false;
   for(int k = posUpper(0); k > 1; k--) // initially k > 0
   {
      if(BullStoch(k) == true)
      {
         stoch = true;
      }
   }
   
   if(stoch == true && pos == true)
   {
      return true;
   }
   return false;
}

bool BullHeiken(int candle)
// returns true if the candle specified is a bullish candle
{
   double ashi = iCustom(_Symbol,PERIOD_M1,"Heiken Ashi",1,candle);
   double high = iHigh(_Symbol,PERIOD_M1,candle);
   if(ashi == high) 
      {return true;}
   else
      {return false;}
}


int BullCandle()
{
   for(int i = posUpper(0); i > 0; i--)
   {
      if(BullStoch(i) == true)
      {
         return 5*(i-1);
      }
   }
   return 100;
}

bool oneque()
// returns true if the one min que is true
{
   double atr = iATR(_Symbol,PERIOD_M1,10,0) + 0.0001;
   bool bullish = true;
   int x = 0;
   
   while(bullish == true)
   {
      if(BullHeiken(x+1) != true) // initially BullHeiken(x)
      {
         if(x == 0) 
         {
            return false;
         }
         else 
         {
            bullish = false;
         }
      }
      x++;
      if(BullCandle() < x)
      {
         return false;
      }
   }
   x -= 2;
   double diff = Ask - iLow(_Symbol,PERIOD_M1,x);
   if(diff > atr) 
   {
      return true;
   }
   else
   {
      return false;
   }
}

bool otherque()
// makes sure the price has not broken the previous upper or lower fractal
{
   for(int i = posUpper(0); i > 0; i--)
   {
      if(upper(0) < iHigh(_Symbol,PERIOD_M5,i))
      {
         return false;
      }
   }

   for(int k = posLower(0); k > 0; k--)
   {
 //     if(lower(0) > iLow(_Symbol,PERIOD_M5,k))
      if(iClose(_Symbol,PERIOD_M5,posLower(0)) > iClose(_Symbol,PERIOD_M5,k))
      {
         return false;
      }
   }
   return true;
}

void OnTick()
{
   if(OrdersTotal() == 0 && oneque() == true && fiveque() == true && otherque() == true)
   {
      double profit = upper(0) - _Point*10;
     //double profit = Ask + _Point*10
      double up = upper(0) - Ask;
      double down = iLow(_Symbol,PERIOD_M5,2);
      for(int i = 3; i > 0; i--)
      {
         if(down > iLow(_Symbol,PERIOD_M5,i))
         {
            down = iLow(_Symbol,PERIOD_M5,i);
         }
      }
      down = Ask - down;
      if(up > down)
      {
         profit = Ask + down;
      } 
      double stoploss = Ask - down - 10*_Point;
      double enter = Ask + _Point*5;
      if(up/down > 0.7 && Ask < profit)
      {
         int ticket = OrderSend(_Symbol,OP_BUY,0.01,enter,3,stoploss,profit,NULL,0,0,Green);  
      }
      else
      {
         if (Ask < profit)
         {
            profit = Ask + down*0.1;
            int ticket1 = OrderSend(_Symbol,OP_BUY,0.01,Ask,3,stoploss,profit,NULL,0,0,Green); 
         }
      }
   }
}


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
   double prevStoch = iStochastic(_Symbol,PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,i+2);
   double Stoch = iStochastic(_Symbol,PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,i+1);
   if (Stoch < 50 && prevStoch >= 50) 
         return true;
   else 
      return false;
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
            return i;

         else 
         {
            count++;
            continue;
         }
      }
      else
          continue;
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
   
int BullCandle()
// gets the candle in 1 min time frame where the stochastic crosses under 50
{
   for(int i = posUpper(0); i > 0; i--)
   {
      if(BullStoch(i) == true)
         return 5*(i-1);
   }
   return 1000;
}
   
bool BullHeiken(int candle)
// returns true if the candle specified is a bullish candle
{
   double ashi = iCustom(_Symbol,PERIOD_M1,"Heiken Ashi",1,candle);
   double high = iHigh(_Symbol,PERIOD_M1,candle);
   if(ashi == high) 
      return true;
      else
      return false;
}
 
bool invalid()
{
   if(posLower(0) > 2)
   {
     for(int k = posLower(1); k > posLower(0); k--)
      {
         if(iClose(_Symbol,PERIOD_M5,k) < lower(2))
            return true;
      } 
   }
   else
   {
      for(int i = posLower(0); i > 0; i--)
      {
         if(iClose(_Symbol,PERIOD_M5,i) < lower(1))
            return true;
      }
   }
   return false;
}  
   
bool que()
// checks all the conditions
{
   bool pos = false;
   // pos = true is a candle has closed above the prev upper fractal
   for(int i = posUpper(1); i > posUpper(0); i--)
   {
      if(iHigh(_Symbol,PERIOD_M5,posUpper(1)) < iClose(_Symbol,PERIOD_M5,i))
         pos = true;
   }    
   bool stoch = false;
   int k;
   for(k = 0; BullHeiken(k) == true; k++); 
   // k = the number of consecutive bullish heiken ashi candle (one min condition)
   if(k != 0) 
   {
      double diff = Ask - iLow(_Symbol,PERIOD_M1,k-1);
      double atr = iATR(_Symbol,PERIOD_M1,10,0) + 0.0001;
      // checls if bullish heiken ashi candle range is greater than atr
      if(BullCandle() != 1000 && k < BullCandle() && diff > atr)
         stoch = true;
   }
   if(stoch == true && pos == true)
      return true;
      
      return false;
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
      if(lower(0) > iLow(_Symbol,PERIOD_M5,k))
      {
         return false;
      }
   }
   return true;
} 
   
void OnTick()
{
   int ticket;
   if(que() == true && OrdersTotal() == 0 && otherque() == true && invalid() == false)
   {
      double down = iLow(_Symbol,_Period,2);
      // find the low of the low of prev 5m min candles
      for(int i = 3; i > 0; i--)
      {
         if(down > iLow(_Symbol,PERIOD_M5,i))
            down = iLow(_Symbol,PERIOD_M5,i);
      }
      double stoploss = down - 10*_Point;
      double enter = Ask + _Point*5;
      double profit = (Ask - stoploss)*0.7 + Ask;
      RefreshRates();
      ticket = OrderSend(_Symbol,OP_BUYSTOP,0.01,Ask+5*Point,2,stoploss,profit,NULL,0,0,Green);  
   }
   bool res = OrderSelect(ticket,SELECT_BY_TICKET);
   if(res != false)
   {
      if(otherque() == false && OrderType() ==  4)
      {
         OrderDelete(ticket,Red);
      }
   }
}
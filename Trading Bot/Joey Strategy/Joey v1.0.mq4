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
// gets the candle number of previosu upper fractal
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
// gets the candle number of previosu upper fractal
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
{
   if(upper(0) < upper(1)) 
   {
      return false;
   }
   
   bool pos = false;
   for(int i = posUpper(1); i > posUpper(0); i--)
   {
      if(iHigh(_Symbol,PERIOD_M5,posUpper(1)) < iClose(_Symbol,PERIOD_M5,i))
      {
         pos = true;
      }
   }
   
   bool stoch = false;
   for(int k = posUpper(0); k > 0; k--)
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
{
   double ashi = iCustom(_Symbol,PERIOD_M1,"Heiken Ashi",1,candle);
   double high = iHigh(_Symbol,PERIOD_M1,candle);
   if(ashi == high) 
      {return true;}
   else
      {return false;}
}

bool oneque()
{
   double atr = iATR(_Symbol,PERIOD_M1,10,0) + 0.0001;
   bool bullish = true;
   int x = 0;
   
   while(bullish == true)
   {
      if(BullHeiken(x) != true)
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
   if(OrdersTotal() == 0 && oneque() == true && fiveque() == true && otherque() == true)
   {
       int ticket = OrderSend(_Symbol,OP_BUY,0.01,Ask,3,lower(0),upper(0),NULL,0,0,Green);  
   }
   
}


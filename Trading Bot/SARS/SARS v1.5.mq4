int posSwitch()
{
   double sar = iSAR(_Symbol,_Period,0.02,0.05,1);
   if(Ask > sar)
     {
      for(int i = 1;; i++)
        {
         double t1 = iSAR(_Symbol,_Period,0.02,0.05,i);
         if(iClose(_Symbol,_Period,i) < t1)
            return i;
        }
     }
   else
     {
      for(int k = 0;; k++)
        {
         double t2 = iSAR(_Symbol,_Period,0.02,0.05,k);
         if(iClose(_Symbol,_Period,k) > t2)
            return k;
        }
     }
}

bool sectionTrade()
// allows 1 trade per section
{
   if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS) == true)
   {
      long OpenTime = OrderOpenTime();
      long SwitchTime = iTime(_Symbol,_Period,posSwitch()-1);
      
      if(OpenTime > SwitchTime)
         return true;
   }
   return false;
}

void OnTick()
{
   double ticket;
   double ent = 0;
   double stop;
   double profit;
   
   double sar = iSAR(_Symbol,_Period,0.02,0.05,0);
   double c1 = iClose(_Symbol,_Period,1);
   double c2 = iClose(_Symbol,_Period,2);
   double ema20 = iMA(_Symbol,_Period,20,0,MODE_EMA,PRICE_CLOSE,1);
   double ema50 = iMA(_Symbol,_Period,50,0,MODE_EMA,PRICE_CLOSE,1);
   
   if(Ask > sar)
   // looking for long position
   {
      bool enter = false;
      if(posSwitch() == 2)
      {
         if(c1 > ema20 && c1 > ema50)
            enter = true;
      }
      else if(posSwitch() == 3)
      {
         if(c1 > ema20 && c1 > ema50)
            enter = true;
      }
      double high = iHigh(_Symbol,_Period,1);
      double low = iLow(_Symbol,_Period,1);
      
      ent = high+10*_Point;
      stop = low-10*_Point;
      double point = (ent - stop)*100000;
      double lot = AccountBalance()*0.01/point;
      
      if(ent != 0 && stop !=0)
         profit = Ask + (ent-stop)*2.5;
      if(enter == true && sectionTrade() == false)
         ticket = OrderSend(_Symbol,OP_BUYSTOP,lot,ent,2,stop,profit,NULL,0,0,Green); 
   }
   
   if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS) == true)
   // invalidation: if Ask goes under ema, delete the pending order
   {
      if(OrderType() == 4)
      {
         if(c1 < ema20 && c1 < ema50)
            OrderDelete(OrderTicket(),Yellow);
      }
   }
   
   if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS) == true)
   // moves the stoploss up to entry if Ask goes over 1R
   {
      if(OrderType() == 0)
      {
         ent = OrderOpenPrice();
         stop = OrderStopLoss();
         profit = OrderTakeProfit();
         double up = c1 - ent;
         double down = ent - stop;
         
         if(up > down && c2 < Ask && c1 > Ask)
            OrderModify(OrderTicket(),0,ent,profit,0,White);
      }
      
   }
}
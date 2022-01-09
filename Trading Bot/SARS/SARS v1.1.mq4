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

void OnTick()
{
   double sar = iSAR(_Symbol,_Period,0.02,0.05,0);
   if(Ask > sar)
   // looking for long position
   {
      bool enter = false;
      double c1A = iClose(_Symbol,_Period,1);
      double c2A = iClose(_Symbol,_Period,2);
      double ema20A = iMA(_Symbol,_Period,20,0,MODE_EMA,PRICE_CLOSE,0);
      double ema50A = iMA(_Symbol,_Period,50,0,MODE_EMA,PRICE_CLOSE,0);
      if(posSwitch() == 1)
      {
         if(c1A > ema20A && c1A > ema50A)
            enter = true;
      }
      else if(posSwitch() == 2)
      {
         if((c1A > ema20A || c2A > ema20A) && (c1A > ema50A || c2A > ema50A))
            enter = true;
      }
      double entA = Ask+10*Point;
      double stopA = iLow(_Symbol,_Period,0)-10*Point;
      double profitA = entA + (entA - stopA)*1.8;
      if(enter == true && OrdersTotal() == 0)
         double ticketA = OrderSend(_Symbol,OP_BUYSTOP,0.01,entA,2,stopA,profitA,NULL,0,0,Green); 
   }
   
   bool res = OrderSelect(ticketA,SELECT_BY_TICKET);
   if(res != false)
   {
      if(Ask < OrderStopLoss() && OrderType() ==  4)
      {
         OrderDelete(ticketA,Red);
      }
   }
}

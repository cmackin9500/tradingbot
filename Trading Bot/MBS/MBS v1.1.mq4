bool BullHeiken(int candle)
// returns true if the candle specified is a bullish candle
{
   double ashi = iCustom(_Symbol,PERIOD_M30,"Heiken Ashi",1,candle);
   double high = iHigh(_Symbol,PERIOD_M30,candle);
   if(ashi == high) 
      return true;
      else
      return false;
}

bool BullTrade()
{
   for(int i = OrdersTotal(); i>=0; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS) == true)
      {
         if(OrderType() == 0)
            return true;
      }
   }  
   return false;
}

bool BearTrade()
{
   for(int i = OrdersTotal(); i>=0; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS) == true)
      {
         if(OrderType() == 1)
            return true;
      }
   }  
   return false;
}

void OnTick()
{
   if(BullTrade() == true)
   {
      for(int i = OrdersTotal(); i >= 0; i--)
      {
         if(OrderSelect(i,SELECT_BY_POS) == true)
         {
            if(OrderType() == 4)
               OrderDelete(OrderTicket(),Yellow);
         }
      }
   }
   
   if(BearTrade() == true)
   {
      for(int k = OrdersTotal(); k >= 0; k--)
      {
         if(OrderSelect(k,SELECT_BY_POS) == true)
         {
            if(OrderType() == 5)
               OrderDelete(OrderTicket(),Yellow);
         }
      }
   }
   
   double m1 = iBands(_Symbol, _Period, 20,2,0, PRICE_CLOSE, MODE_MAIN,1);
   double m2 = iBands(_Symbol, _Period, 20,2,0, PRICE_CLOSE, MODE_MAIN,2);
   double c1 = iClose(_Symbol,_Period,1);
   double c2 = iClose(_Symbol,_Period,2);
   
   double low = iLow(_Symbol,_Period,1);
   double high = iHigh(_Symbol,_Period,1);
   
   double entry,sl,tp,lot;
   
   if(BullTrade() == false)
   {
      if(m1<c1 && m2>c2 && BullHeiken(1) == true)
      {
         entry = high + 10*_Point;
         sl = low - 10*_Point;
         tp = entry + (entry-sl)*3;
         double pointA = (entry - sl)*100000;
         double lotA = AccountBalance()*0.01/pointA;
         OrderSend(_Symbol,OP_BUYSTOP,lotA,entry,1,sl,tp,NULL,0,0,Green);
      }
   }
   
   if(BearTrade() == false)
   {
      if(m1>c1 && m2<c2 && BullHeiken(1) == false)
      {
         entry = low - 10*_Point;
         sl = high + 10*_Point;
         tp = entry - (sl-entry)*3;
         double pointB = (sl - entry)*100000;
         double lotB = AccountBalance()*0.01/pointB;
         OrderSend(_Symbol,OP_SELLSTOP,lotB,entry,1,sl,tp,NULL,0,0,Green);
      }
   }
   
   for(int j = OrdersTotal(); j>=0; j--)
   {
      if(OrderSelect(j,SELECT_BY_POS) == true)
      {
         if(OrderType() == 4)
         {
            if(c1<m1)
               OrderDelete(OrderTicket(),Pink);
         }
      }
   }
   
   for(int z = OrdersTotal(); z>=0; z--)
   {
      if(OrderSelect(z,SELECT_BY_POS) == true)
      {
         if(OrderType() == 5)
         {
            if(c1>m1)
               OrderDelete(OrderTicket(),Pink);
         }
      }
   }
   
   for(int p = OrdersTotal(); p>=0; p--)
   {
      if(OrderSelect(p,SELECT_BY_POS) == true)
      // moves the stoploss up to entry if Ask goes over 1R
      {
         double up,down;
         if(OrderType() == 0)
         {
            entry = OrderOpenPrice();
            sl = OrderStopLoss();
            tp = OrderTakeProfit();
            up = c1 - entry;;
            down = entry - sl;
            if(up > down && c2 < Ask && c1 > Ask)
               OrderModify(OrderTicket(),0,entry,tp,0,White);
         }   
         if(OrderType() == 1)
         {
            entry = OrderOpenPrice();
            sl = OrderStopLoss();
            tp = OrderTakeProfit();
            down = entry - c1;
            up = sl - entry;
            
            if(up < down && c2 > Ask && c1 < Ask)
               OrderModify(OrderTicket(),0,entry,tp,0,White);
         }  
      }
   }
}
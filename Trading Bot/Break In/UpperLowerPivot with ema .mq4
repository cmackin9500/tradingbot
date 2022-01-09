datetime last;

void safety()
{
   double c1 = iClose(_Symbol,_Period,1);
   double c2 = iClose(_Symbol,_Period,2);
   
   for(int i = OrdersTotal(); i>=0; i--)
   {
      double tp,sl,entry,R;
      if(OrderSelect(i,SELECT_BY_POS) == true)
      {
         if(OrderType() == 0)
         {
            tp = OrderTakeProfit();
            sl = OrderStopLoss();
            entry = OrderOpenPrice();
            
            R = entry + (entry-sl);
            if(c1 > R && c2 < R)
               OrderModify(OrderTicket(),0,entry,tp,0,White);
         }
         if(OrderType() == 1)
         {
            tp = OrderTakeProfit();
            sl = OrderStopLoss();
            entry = OrderOpenPrice();
            R = entry - (sl-entry);
            if(c1 < R && c2 > R)
               OrderModify(OrderTicket(),0,entry,tp,0,White);
         }
      }
   }
}

void OnTick()
{
   double pivot,upper1,upper2,lower1,lower2,c1,c2,high,low;
   double entry,sl,tp,lot,point;
   double et = TimeCurrent() + PERIOD_H1*60*10;
   double ema = iMA(_Symbol,_Period,180,1,MODE_EMA,PRICE_CLOSE,1);
   if(last!=Time[0])
   {
      safety();
      pivot = iCustom(_Symbol,_Period,"PivotDay",0,1);
      high = iHigh(_Symbol,_Period,1);
      low = iLow(_Symbol,_Period,1);
      upper1 = iBands(_Symbol,_Period,15,2,1,PRICE_CLOSE,MODE_UPPER,1);
      upper2 = iBands(_Symbol,_Period,15,2,1,PRICE_CLOSE,MODE_UPPER,2);
      lower1 = iBands(_Symbol,_Period,15,2,1,PRICE_CLOSE,MODE_LOWER,1);
      lower2 = iBands(_Symbol,_Period,15,2,1,PRICE_CLOSE,MODE_LOWER,2);
      c1 = iClose(_Symbol,_Period,1);
      c2 = iClose(_Symbol,_Period,2);
      
      if(c1>lower1 && c2<lower2 && pivot>low && pivot<high /*&& c1 > ema*/)
      {
         entry = iHigh(_Symbol,_Period,1) + (10*_Point);
         sl = iLow(_Symbol,_Period,1) - (10*_Point);
         tp = entry + (3 * (entry - sl));
         point = entry - sl;
         lot = 10/(point*100000);
         OrderSend(_Symbol,OP_BUYSTOP,lot,entry,2,sl,tp,NULL,0,et,Green);
      }
      if(c1<upper1 && c2>upper2 && pivot>low && pivot<high /*&& c1 < ema*/)
      {
         entry = iLow(_Symbol,_Period,1) - (10*_Point);
         sl = iHigh(_Symbol,_Period,1) + (10*_Point);
         tp = entry - (3 * (sl - entry));
         point = sl - entry;
         lot = 10/(point*100000);
         OrderSend(_Symbol,OP_SELLSTOP,lot,entry,2,sl,tp,NULL,0,et,Green);      
      }
   }
   last=Time[0];
}
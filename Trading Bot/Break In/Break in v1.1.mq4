datetime last;
bool open = false;

void invalid()
{
   double c = iClose(_Symbol,_Period,1);
   for(int i = OrdersTotal(); i>=0; i--)
   {
      double upper1 = iBands(_Symbol,_Period,15,2,1,PRICE_CLOSE,MODE_UPPER,1);
      double lower1 = iBands(_Symbol,_Period,15,2,1,PRICE_CLOSE,MODE_LOWER,1);
      if(OrderSelect(i,SELECT_BY_POS) == true)
      {
         if(OrderType() == 4)
         {
            if(c < lower1)
               OrderDelete(OrderTicket(),Pink);
         }
         if(OrderType() == 5)
         {
            if(c > upper1)
               OrderDelete(OrderTicket(),Pink);
         }
      }
   }
}

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

bool hit()
{
   double high,low,pivot;
   for(int i = 0; i < 10; i++)
   {
      high = iHigh(_Symbol,_Period,i);
      low = iLow(_Symbol,_Period,i);
      pivot = iCustom(_Symbol,_Period,"PivotDay",0,i);
      
      if(high > pivot && low < pivot)
         return true;
   }
   return false;
}

bool BullTrade()
{
   for(int i = OrdersTotal(); i>=0; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS) == true)
      {
         if(OrderType() == 4)
            return true;
         else if(OrderType() == 0)
         {
            if(OrderOpenPrice() != OrderStopLoss())
               return true;
         }
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
         if(OrderType() == 5)
            return true;
         else if(OrderType() == 1)
         {
            if(OrderOpenPrice() != OrderStopLoss())
               return true;
         }
      }
   }  
   return false;
}

void openTrade()
{
   string time = TimeToStr(TimeCurrent());
   time = StringSubstr(time,11,5);  
   if((time == "07:00") || (time == "13:00"))
      open = true;
   if((time == "11:00") || (time == "16:00"))
      open = false;
}

void OnTick()
{
   openTrade();
   double pivot,upper1,upper2,lower1,lower2,c1,c2,high,low;
   double entry,sl,tp,lot,point;
   double et = TimeCurrent() + PERIOD_H1*60*10;
   double ema = iMA(_Symbol,_Period,180,1,MODE_EMA,PRICE_CLOSE,1);
   
if(open == true)
{
   if(last!=Time[0])
   {
      invalid();
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
      
      if(c1>lower1 && c2<lower2 && hit() == true && BullTrade() == false)
      {
         entry = iHigh(_Symbol,_Period,1) + (10*_Point);
         sl = iLow(_Symbol,_Period,1) - (10*_Point);
         tp = entry + (3 * (entry - sl));
         point = entry - sl;
         lot = 10/(point*100000);
         OrderSend(_Symbol,OP_BUYSTOP,lot,entry,2,sl,tp,NULL,0,et,Green);
      }
      if(c1<upper1 && c2>upper2 && hit() == true && BearTrade() == false)
      {
         entry = iLow(_Symbol,_Period,1) - (10*_Point);
         sl = iHigh(_Symbol,_Period,1) + (10*_Point);
         tp = entry - (3 * (sl - entry));
         point = sl - entry;
         lot = 10/(point*100000);
         OrderSend(_Symbol,OP_SELLSTOP,lot,entry,2,sl,tp,NULL,0,et,Green);   
      }
   }
}
   last=Time[0];
}
int posSwitch()
{
   double sar = iSAR(_Symbol,_Period,0.02,0.2,1);
   if(Ask > sar)
     {
      for(int i = 1;; i++)
        {
         double t1 = iSAR(_Symbol,_Period,0.02,0.2,i);
         if(iClose(_Symbol,_Period,i) < t1)
            return i;
        }
     }
   else
     {
      for(int k = 0;; k++)
        {
         double t2 = iSAR(_Symbol,_Period,0.02,0.2,k);
         if(iClose(_Symbol,_Period,k) > t2)
            return k;
        }
     }
}

void OnTick()
{
   //Print("posSwtich(): ",posSwitch());
   //Print("iClose: ", iClose(_Symbol,_Period,0));
   double sar = iSAR(_Symbol,_Period,0.02,0.2,0);
   if(Ask > sar)
   // looking for long position
   {
      bool enter = false;
      double c1 = iClose(_Symbol,_Period,1);
      //double c2 = iClose(_Symbol,_Period,2);
      double ema20 = iMA(_Symbol,_Period,20,0,MODE_EMA,PRICE_CLOSE,1);
      double ema50 = iMA(_Symbol,_Period,50,0,MODE_EMA,PRICE_CLOSE,1);
      if(posSwitch() == 1)
      {
         if(c1 > ema20 && c1 > ema50)
            enter = true;
      }
      else if(posSwitch() == 2)
      {
         if(c1 > ema20 && c1 > ema50)
            enter = true;
      }
      double high = iHigh(_Symbol,_Period,1);
      double low = iLow(_Symbol,_Period,1);
      
      double ent = high+10*_Point;
      double stop = low-10*_Point;
      double profit;
      if(ent != 0 && stop !=0)
         profit = Ask + (ent-stop)*1.8;
      if(enter == true && OrdersTotal() == 0)
         double ticket = OrderSend(_Symbol,OP_BUYSTOP,0.01,ent,2,stop,profit,NULL,0,0,Green); 
   }

/*   if(OrderSelect(ticket,SELECT_BY_TICKET) == true)
   {
      double up = Ask - OrderOpenPrice();
      double down = OrderOpenPrice() - OrderStopLoss();
      if(up/down > 1)
      {
         OrderModify(ticket,OrderOpenPrice(), OrderOpenPrice(),OrderTakeProfit(),NULL,Orange);
      }
   }
/*
   bool res = OrderSelect(ticket,SELECT_BY_TICKET);
   if(res != false)
   {
      if(Ask < OrderStopLoss() && OrderType() ==  4)
      {
         OrderDelete(ticket,Red);
      }
   }*/
}

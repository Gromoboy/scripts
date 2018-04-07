-- SyncTradesTest.lua
running = true                -- ���� ������ �������
TRADE_ACC="4100R24"           -- �������� ����
CLASS_CODE_FUT="SPBFUT"       -- ����� ���������
SEC_CODE_FUT_FOR_OPEN="SiU6"  -- ��� ������ (��������)
TRANS_ID=0                    	-- ������������� ����������, ���������� ������������� ��� ������� �� QLUA

-- 
local logfile = 0 				-- ���� ��� ������ �����
-- ��������������� ����������
local teststarted = false		-- ���� ����������� ������������
local lastorder_ticket=""		-- ����� ���������� ������������� ������ (������)
local lastorderTPSL=""			-- ����� ���������� ������ �� ��������� �������� ������ TP&SL	
local lastTPSL_trans_id=""		-- ����� ��������� ���������� �� ��������� �������� ������ TP&SL	
local last_operation="No"		-- ��� ��������� ����������
local trades_limit=10;			-- ���������� ������� � �����
-- �������� �������
local start,finish			  	-- ����� ������ � ����� ������������
local topen_start,topen_finish	-- ������ � ������������� �������� �������
local tclose_start,tclose_stop	-- ������ � ������������� �������� �������
local torder_start
local torder_finish 			-- ������ � ������������� ����������� �������� ������
local tdelete_start
local tdelete_finish 			-- ������ � ������������� �������� �������� ������
local timeOpen,timeClose 		-- ����� ����������� ����� �� �������� �������/�������, ����� �������� ������� ��������
local timeSet, timeDelete		-- ����� ����������� ����� �� �������� ���������/������, ����� �������� ������� ��������
local tradecounter              -- ������� ����������� �������
local transIDstart				-- ��������� ����� ���������� �������� �� ������ ������ � �������

-- ��������� ��������
local ready="READY"    			-- ����� �������� �������
local startSeries="seriesStarted"-- �������� ����� �������� ��������
local buyDone="buyDone"  		-- ������� ���������
local SetOrder="SetOrder" 		-- ���������� ������ TP&SL
local sellDone="sellDone"		-- ������� ���������
local deleteDone="deleteDone"	-- ����� ������ TP&SL
local seriesDone="seriesDone"	-- ����� �������� �������� ���������
local noChanges="noChanges"		-- ��������� �� ����������
local state=ready
-- ���� ��������
local BUY="BUY"
local SELL="SELL"
local SETORDER="SETORDER"
local DELETEORDER="DELETEORDER"

-- ��������������� ����������, ����� �������� ������������� ������ OnTrade() � OnOrder()
local ontrade_event=""			-- ������ trans_id+order_num
local onorder_event=""			-- ������ trans_id+order_num

-- ��� ������� ������� �������, ����������� ������������� � ������ �������� ���� ��� �� ��������� 
function main()
	-- �������� ������� ���� � ������ "������/������"
	logfile = io.open(getScriptPath().."\\SyncTradesTest_log.txt","a+");
	-- ���� ���� �� ����������
	if logfile == nil then 
		-- ������� ���� � ������ "������"
		logfile = io.open(getScriptPath().."\\SyncTradesTest_log.txt","w"); 
		-- ��������� ����
		logfile:close();
		-- ��������� ��� ������������ ���� � ������ "������/������"
		logfile = io.open(getScriptPath().."\\SyncTradesTest_log.txt","r+");
	end;
	-- ���� ������������� ������ ��� ��������� ������� �������������
    while running do
		--message(os.date().. "running SyncTradesTest.lua") --��� � 15 ������ ������� ������� ���� � �����
        sleep(15000)
    end
	logfile:flush();
	logfile:close();
end

-- ���������� ��� ������ ���������� ������� ���������
function OnQuote(class, sec ) 
	-- �������� ����� �������
	if (teststarted==false) then
		teststarted=true;
		message("SyncTradesTest.lua starting");
		Print("SyncTradesTest.lua starting...");
		StartSeries(trades_limit);   -- ��������� �������� ���������� � �������
		start=os.clock();			  -- ����� ������
		Buy()
	end
end

-- ������� �����������
function Buy()
	transIDstart=transIDstart+1
    TRANS_ID = transIDstart
	Print((tradecounter+1)..". Buy".." TRANS_ID="..TRANS_ID)
   -- ��������� ��������� ��� �������� ���������� �� ������� 1 ���� 
    local Transaction={
      ["TRANS_ID"]   = tostring(TRANS_ID),
      ["ACTION"]     = "NEW_ORDER",
      ["CLASSCODE"]  = CLASS_CODE_FUT,
      ["SECCODE"]    = SEC_CODE_FUT_FOR_OPEN,
      ["OPERATION"]  = "B", -- ������� (BUY)
      ["TYPE"]       = "M", -- �� ����� (MARKET)
      ["QUANTITY"]   = "1", -- ����������
      ["ACCOUNT"]    = TRADE_ACC,
      ["PRICE"]      = tostring(getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "offer").param_value + 30*getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "SEC_PRICE_STEP").param_value), -- �� ����, ���������� �� 30 ���. ����� ����
      ["COMMENT"]    = string.format("Trade #d Buy %s at %s",(tradecounter+1),SEC_CODE_FUT_FOR_OPEN,os.date("%Y.%m.%d %H:%M:%S"))
    }
    -- ��� ���������, �� ����� ���� ����� ��������
        local price=getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "offer").param_value
    --message("Offer Price="..price)
    -- ����� �������� �������� ���������� �� ������
	topen_start=os.clock();  -- ������ �������
	last_operation=BUY
    local Result = sendTransaction(Transaction);
    -- ��������, �� �� ���������
	if Result ~= "" then
		message("������� �� �������!\n������: "..tostring(Result));
    end;    
end

-- ������� �����������
function Sell()
	transIDstart=transIDstart+1
    TRANS_ID = transIDstart
	Print((tradecounter+1)..". Sell".." TRANS_ID="..TRANS_ID)
   -- ��������� ��������� ��� �������� ���������� �� ������� 1 ���� 
    local Transaction={
      ["TRANS_ID"]   = tostring(TRANS_ID),
      ["ACTION"]     = "NEW_ORDER",
      ["CLASSCODE"]  = CLASS_CODE_FUT,
      ["SECCODE"]    = SEC_CODE_FUT_FOR_OPEN,
      ["OPERATION"]  = "S", -- ������� (BUY)
      ["TYPE"]       = "M", -- �� ����� (MARKET)
      ["QUANTITY"]   = "1", -- ����������
      ["ACCOUNT"]    = TRADE_ACC,
      ["PRICE"]      = tostring(getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "bid").param_value - 30*getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "SEC_PRICE_STEP").param_value), -- �� ����, ���������� �� 30 ���. ����� ����
      ["COMMENT"]    = string.format("Trade #d Sell %s at %s",(tradecounter+1),SEC_CODE_FUT_FOR_OPEN,os.date("%Y.%m.%d %H:%M:%S"))
    }
    -- ��� ���������, �� ����� ���� ����� ���������
	local price=getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "bid").param_value
    --message("Bid Price="..price)
    -- ����� �������� �������� ���������� �� ������
	tclose_start=os.clock();  -- ������ �������
	last_operation=SELL	
    local Result = sendTransaction(Transaction);
    -- ��������, �� �� ���������
	if Result ~= "" then
		message("������� �� �������!\n������: "..tostring(Result));
    end;    
end

--
function sendOrderTP_SL()
	transIDstart=transIDstart+1
    TRANS_ID = transIDstart
	Print((tradecounter+1)..". Send TP&SL".." TRANS_ID="..TRANS_ID)
	
    -- ��� ���������, �� ����� ���� ����� ���������
	local price=getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "bid").param_value
    --message("Bid Price="..price)
	priceStop = tostring(math.floor(getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, 'PRICEMAX').param_value)); -- ���� ������������ ������ ����� ������������� ����� ����������� ���������, ����� �� �������������
	-- ��������� ��������� ��� �������� ���������� �� ������� 1 ���� 
    local Transaction={
		["TRANS_ID"]   = tostring(TRANS_ID),
		["ACTION"]     = "NEW_ORDER",
		["CLASSCODE"]  = CLASS_CODE_FUT,
		["SECCODE"]    = SEC_CODE_FUT_FOR_OPEN,
		["ACCOUNT"]    = TRADE_ACC,		
		["QUANTITY"] = "1",
		["STOP_ORDER_KIND"] = "TAKE_PROFIT_AND_STOP_LIMIT_ORDER",
		["OPERATION"] = "S", -- ��� �������� ������� "B" - �������(BUY), ��� ������� - "S" �������(SELL))
		["STOPPRICE"] = tostring(price+200), --���� ��������� ���� �������
		["OFFSET"] = "50",
		["OFFSET_UNITS"] = "PRICE_UNITS",
		["MARKET_TAKE_PROFIT"] = "YES",
		["PRICE"] = priceStop,
		["STOPPRICE2"] = tostring(price-200), --���� ����
		["IS_ACTIVE_IN_TIME"] = "YES",
		["ACTIVE_FROM_TIME"] = "100000",   -- ����:������:�������
		["ACTIVE_TO_TIME"] = "234545",     -- ����:������:�������
		["MARKET_STOP_LIMIT"] = "YES",
		["COMMENT"]    = string.format("Trade #d Set TP&SL for %s at %s",(tradecounter+1),SEC_CODE_FUT_FOR_OPEN,os.date("%Y.%m.%d %H:%M:%S"))
    }
    -- ����� �������� �������� ���������� �� ������
	torder_start=os.clock();  -- ������ �������� �������� ������
	last_operation=SETORDER	
    local Result = sendTransaction(Transaction);
    -- ��������, �� �� ���������
	if Result ~= "" then
		message("��������� ������ TP&SL �� �������!\n������: "..tostring(Result));
    end;
end;

-- �������� ���������� ������
function DeleteOrder()
	--transIDstart=transIDstart+1
	TRANS_ID = lastTPSL_trans_id -- transIDstart
	Print((tradecounter+1)..". Delete TP&SL #"..lastorderTPSL.." TRANS_ID="..TRANS_ID)
	-- ��������� ��������� ��� ������ ������ ���������� 
    local Transaction={
		["TRANS_ID"]   = tostring(TRANS_ID),
		["ACTION"]     = "KILL_ORDER",
		["CLASSCODE"]  = CLASS_CODE_FUT,
		["SECCODE"]    = SEC_CODE_FUT_FOR_OPEN,
		["ACCOUNT"]    = TRADE_ACC,		
		["ORDER_KEY"] = tostring(lastorderTPSL),
		["COMMENT"]    = string.format("Trade #d Delete order %d at %s",(tradecounter+1),lastorderTPSL,os.date("%Y.%m.%d %H:%M:%S"))
    }
    -- ����� �������� �������� ���������� �� ������
	tdelete_start=os.clock();  -- ������ �������� ������� �� �������� �������� ������ 
	last_operation=DELETEORDER	
    local Result = sendTransaction(Transaction);
    -- ��������, �� �� ���������
	if Result ~= "" then
		message("�������� ������ ������ TP&SL #"..lastorderTPSL.." �� �������!\n������: "..tostring(Result));
    end;
end;

-- ���������� ��������
function StartSeries(total_trades)
	trades_limit=total_trades
	timeOpen=0
	timeClose=0
	timeSet=0
	timeDelete=0
	tradecounter=0; 	
	minutes=os.date("%M")
	seconds=os.date("%S")
	transIDstart=minutes*10000+seconds*100
end

-- ���������� ��� ��������� ����� ����-������ ��� ��� ��������� ���������� ������������ ����-������
function OnTrade(order)
    --Print(tradecounter..". OnTrade #"..order.order_num.." Flags="..order.flags..order.system_ref) 
	-- ������������ ������� ������ ��������� ����������
	if(order.trans_id~=TRANS_ID) then	
		return -- ��������� ������� (���������, ��������) ����������, ��� ��� ��� ������ ������ ������
	end
	-- ������� ����� ��������� 3 ����, ������������ ������ ������ �����
	curr_ontrade_event=order.trans_id..order.order_num
	if (curr_ontrade_event~=ontrade_event) then
		ontrade_event=curr_ontrade_event
		-- �������� ������� ��������� ��������
		state=CheckState(order, nil, nil);
		--Print("state="..tostring(state));
		-- ���������� ��������� ��������
		ProcessState(state)
	end
end

-- ���������� ��� ��������� ������ �� ���������� ������������, ������������ � ������� Trans2quik.dll, QPILE, QLua 
function OnTransReply(trans_reply)
	-- ������������ ������� ������ ��������� ����������
	if(trans_reply.trans_id~=TRANS_ID) then	
		return -- ��������� ������� (���������, ��������) ����������, ��� ��� ��� ������ ������ ������
	end
    state=CheckState(nil, trans_reply, nil)
	-- ���������� ��������� ��������
	--ProcessState(state)	
end

-- ���������� ���������� QUIK ��� ��������� ����� ������ ��� ��� ��������� ���������� ������������ ������
function OnOrder(order)
	-- ������������ ������� ������ ��������� ����������
	if(order.trans_id~=TRANS_ID) then	
		return -- ��������� ������� (���������, ��������) ����������, ��� ��� ��� ������ ������ ������
	end
	-- ������� ����� ��������� 3 ����, ������������ ������ ������ �����
	curr_onorder_event=order.trans_id..order.order_num
	if (curr_onorder_event~=onorder_event) then
	    onorder_event=curr_onorder_event
		state=CheckState(nil, nil, order)
		-- ���������� ��������� ��������
		ProcessState(state)		
	end
end


-- ���������� �������� � ������������ � ���������� ��������
function ProcessState(currstate)
	-- ������� ��������� ��������
	if(currstate==startSeries) then -- ������������ �������� - ����������� ������ �������	
		start=os.clock();			-- ����� ������
		Buy();                  	-- �������� �������
	end;
	if(currstate==buyDone)  then  	-- ��������� ������� �������
         Sell(); 			   		-- ������� ������� // �������� ������ "Take Profit � Stop Limit"
	end;
	if(currstate==deleteDone) then	-- ������� �������� ������, ����� ��������� ����� �������
         Buy();         			-- ������� �� �����
	end;
	if(currstate==setDone) then     -- ������ ��������� SL � TP
         Sell();    	   			-- ������� �������
	end;
	if(currstate==sellDone) then	-- ������� �������, ������� ������� �������� ������ "Take Profit � Stop Limit"
         Buy();						-- ������� �� �����
	end;
	if(currstate==seriesDone) then  -- ��������� ��������� �� TradeSeries ������� 
		finish=os.clock();  	-- ����� ����������� 
		delta=(finish-start)*1000;
		Print(string.format("Total time=%.1f ms",delta));
		Print(string.format("Average time: Open=%.1f ms, Close %.1f ms (%d series)",
                     timeOpen*1000/tradecounter,timeClose*1000/tradecounter,tradecounter));
		final_msg=string.format("Total series=%d, total time=%.1f ms",tradecounter,delta)
		final_msg=final_msg.."\n"..string.format("Average time: open=%.1f ms, close %.1f ms (%d series)",
                     timeOpen*1000/tradecounter,timeClose*1000/tradecounter,tradecounter)
		message(final_msg);
		-- ��������� ���� � ��������� '����'
		--running = false
		--Print("finishing...");		
	end
	--info=getOnTradeStructure(order,tradecounter);
	--logfile:write(info);
end

-- �������� ���������
function CheckState(orderfromOnTrade, transfromOnTransreply, orderfromOnOrder)
    temp_state=noChanges
    -- ��������� ������ �� OnTransReply	
	if (transfromOnTransreply~=nil) then	
		TransID=transfromOnTransreply.trans_id	-- id ����������
		Flags=transfromOnTransreply.flags
		lastorder_ticket=transfromOnTransreply.order_num
		-- ������� ������ ������
		status=getSatus(transfromOnTransreply.status)
		-- ������� � ���
		Print(string.format("OnTransReply: TransID=%d  %s Flags=%d",TransID,status,Flags))
	end

    -- ��������� ������ �� OnTrade
	if (orderfromOnTrade~=nil) then
		-- ������ ���������, ��������� ������ � �������� �������
		stringdeal=tostring(orderfromOnTrade.trade_num)
		order=orderfromOnTrade.order_num		-- ����� ������
		TransID=orderfromOnTrade.trans_id		-- id ����������
		Flags=orderfromOnTrade.flags
		-- ������� � ���
		Print(string.format("OnTrade: TransID=%d Order_num=%s  Flags=%d",TransID,order,Flags))
		--Print(string.format("%d. TransID=%d order #%s %s %s",(tradecounter+1),TransID, order,last_operation,stringdeal))
		return (noChanges) -- 
	end
    
    -- ��������� ������ �� OnOrder		
	if (orderfromOnOrder~=nil) then	
		order=orderfromOnOrder.order_num		-- ����� ������
		TransID=orderfromOnOrder.trans_id		-- id ����������
		Flags=orderfromOnOrder.flags
		-- ������� � ���
		Print(string.format("OnOrder: TransID=%d Order_num=%s  Flags=%d",TransID,order,Flags))
		
		-- ��������� ���������� ���� �� �������		
		if ((orderfromOnOrder.order_num==lastorder_ticket)and(last_operation==BUY)and(orderfromOnOrder.trade_num~=0)) then 
			topen_finish=os.clock()
			timeOpen=timeOpen+(topen_finish-topen_start)
			lastorder_ticket=0
			last_operation="No"
			Print(string.format("%d. Open time=%.1f ms",(tradecounter+1),(topen_finish-topen_start)*1000))
			-- ��������� ������� 
            Print("���������� �� CheckState state=buyDone")
			return (buyDone)
		end			
		
		-- ��������� ���������� ���� �� �������
		if ((orderfromOnOrder.order_num==lastorder_ticket)and(last_operation==SELL)and(orderfromOnOrder.trade_num~=0)) then 
			tclose_finish=os.clock()
			timeClose=timeClose+(tclose_finish-tclose_start)		
			lastorder_ticket=0
			last_operation="No"
			Print(string.format("%d. Close time=%.1f ms",(tradecounter+1),(tclose_finish-tclose_start)*1000))
			-- ��������� ������� 
			tradecounter=tradecounter+1
			-- ����� ������� ����������
			if(tradecounter>=trades_limit) then
				return(seriesDone) -- ��������� ������������
			end			
			return (sellDone)
		end	
		-- ��������� ���������� ���� �������� ������ "TAKE_PROFIT_AND_STOP_LIMIT_ORDER"
		if ((orderfromOnOrder.order_num==lastorder_ticket)and(last_operation==SETORDER)) then 
			torder_finish=os.clock()
			timeSet=timeSet+(torder_finish-torder_start)
			lastorderTPSL=orderfromOnOrder.order_num
			lastTPSL_trans_id=orderfromOnOrder.trans_id
			lastorder_ticket=0
			last_operation="No"
			Print(string.format("%d. SetOrder time=%.1f ms",(tradecounter+1),(torder_finish-torder_start)*1000))
			-- ����������� �������� ������ "TAKE_PROFIT_AND_STOP_LIMIT_ORDER"
			return (setDone) 
		end

		-- ��������� ���������� ���� "KILL_ORDER"
		if ((orderfromOnOrder.order_num==lastorder_ticket)and(last_operation==DELETEORDER)) then 
			tdelete_finish=os.clock()
			timeDelete=timeDelete+(tdelete_finish-tdelete_start)
			lastorder_ticket=0
			last_operation="No"
			Print(string.format("%d. DeleteOrder time=%.1f ms",(tradecounter+1),(tdelete_finish-tdelete_start)*1000))
			tradecounter=tradecounter+1
			-- ����� ������� ����������
			if(tradecounter>=trades_limit) then
				return(seriesDone) -- ��������� ������������
			end
			-- ����� �������� ������ "TAKE_PROFIT_AND_STOP_LIMIT_ORDER"
			return (deleteDone) 
		end					
	end		
	Print("���������� �� CheckState state="..temp_state)
	return (temp_state)
end


-- ������� ��������� ������� �������������
function OnStop(s)
	-- ��������� ���� � ��������� '����'
	running = false
	Print("SyncTradesTest.lua finishing...");
	return 3000 -- �������� ������� � 3 �������
end

function Print(line)
	if (logfile~=nil) then
	    timestamp=os.date("%Y.%m.%d %H:%M:%S ");
		logfile:write(timestamp.."\t"..line.."\n");
	end
end

function getSatus(statuscode)
	status_string="����������� ������ "..statuscode
	if (statuscode==0) then
		status_string="T��������� ���������� �������"
	end
	if (statuscode==1) then
		status_string="���������� �������� �� ������ QUIK �� �������"
	end
	if (statuscode==2) then
		status_string="������ ��� �������� ���������� � �������� �������"
	end
	if (statuscode==3) then
		status_string="T��������� ���������"
	end
	if (statuscode==4) then
		status_string="T��������� �� ��������� �������� ��������"
	end
	if (statuscode==5) then
		status_string="T��������� �� ������ �������� ������� QUIK �� �����-���� ���������"
	end
	if (statuscode==6) then
		status_string="T��������� �� ������ �������� ������� ������� QUIK"
	end
	if (statuscode==10) then
		status_string="���������� �� �������������� �������� ��������"
	end
	if (statuscode==11) then
		status_string="���������� �� ������ �������� ������������ ����������� �������� �������"
	end
	return status_string
end 

function getOnTradeStructure(trade, k)
structure=""
structure=os.clock()..structure..k..". OnTrade\n"
structure=structure.."   trade_num="..trade.trade_num.."\n"
structure=structure.."   canceled_datetime="..tostring(trade.canceled_datetime).."\n"
structure=structure.."   order_num="..trade.order_num.."\n"
structure=structure.."   brokerref ="..trade.brokerref .."\n"
structure=structure.."   userid="..trade.userid.."\n"
structure=structure.."   firmid="..trade.firmid.."\n"
structure=structure.."   account="..trade.account  .."\n"
structure=structure.."   flags="..trade.flags.."\n"
structure=structure.."   system_ref="..trade.system_ref.."\n"
structure=structure.."   kind ="..trade.kind.."\n"
structure=structure.."   uid ="..trade.uid.."\n"
return structure
end
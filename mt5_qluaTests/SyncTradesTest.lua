-- SyncTradesTest.lua
running = true                -- Флаг работы скрипта
TRADE_ACC="4100R24"           -- Торговый счет
CLASS_CODE_FUT="SPBFUT"       -- Класс ФЬЮЧЕРСОВ
SEC_CODE_FUT_FOR_OPEN="SiU6"  -- Код бумаги (фьючерса)
TRANS_ID=0                    	-- Идентификатор транзакции, задаваемый пользователем при отравке из QLUA

-- 
local logfile = 0 				-- Файл для записи логов
-- вспомогательные переменные
local teststarted = false		-- флаг запущенного тестирования
local lastorder_ticket=""		-- тикет последнего отправленного ордера (заявки)
local lastorderTPSL=""			-- тикет последнего ордера на установку условной заявки TP&SL	
local lastTPSL_trans_id=""		-- номер последней транзакции на установку условной заявки TP&SL	
local last_operation="No"		-- тип последней транзакции
local trades_limit=10;			-- количество трейдов в серии
-- счетчики времени
local start,finish			  	-- время начала и конца тестирования
local topen_start,topen_finish	-- начало и подтверждение операции покупки
local tclose_start,tclose_stop	-- начало и подтверждение операции продажи
local torder_start
local torder_finish 			-- начало и подтверждение выставления условной заявки
local tdelete_start
local tdelete_finish 			-- начало и подтверждение удаления условной заявки
local timeOpen,timeClose 		-- общее затраченное время на операции покупки/продажи, чтобы получить среднее значение
local timeSet, timeDelete		-- общее затраченное время на операции установки/снятия, чтобы получить среднее значение
local tradecounter              -- счетчик проведенных трейдов
local transIDstart				-- начальный номер транзакций задается по номеру минуты и секунде

-- состояния автомата
local ready="READY"    			-- режим ожидания команды
local startSeries="seriesStarted"-- запущена серия торговых операций
local buyDone="buyDone"  		-- покупка проведена
local SetOrder="SetOrder" 		-- установили заявку TP&SL
local sellDone="sellDone"		-- покупка проведена
local deleteDone="deleteDone"	-- сняли заявку TP&SL
local seriesDone="seriesDone"	-- серия торговых операций завершена
local noChanges="noChanges"		-- состояние не изменилось
local state=ready
-- типы операций
local BUY="BUY"
local SELL="SELL"
local SETORDER="SETORDER"
local DELETEORDER="DELETEORDER"

-- вспомогательные переменные, чтобы обходить множественные вызовы OnTrade() и OnOrder()
local ontrade_event=""			-- строка trans_id+order_num
local onorder_event=""			-- строка trans_id+order_num

-- это главная функция скрипта, запускается автоматически и скрипт работает пока она не завершена 
function main()
	-- Пытается открыть файл в режиме "чтения/записи"
	logfile = io.open(getScriptPath().."\\SyncTradesTest_log.txt","a+");
	-- Если файл не существует
	if logfile == nil then 
		-- Создает файл в режиме "записи"
		logfile = io.open(getScriptPath().."\\SyncTradesTest_log.txt","w"); 
		-- Закрывает файл
		logfile:close();
		-- Открывает уже существующий файл в режиме "чтения/записи"
		logfile = io.open(getScriptPath().."\\SyncTradesTest_log.txt","r+");
	end;
	-- флаг переключается только при остановки скрипта пользователем
    while running do
		--message(os.date().. "running SyncTradesTest.lua") --раз в 15 секунд выводит текущие дату и время
        sleep(15000)
    end
	logfile:flush();
	logfile:close();
end

-- вызывается при каждом обновлении стакана котировок
function OnQuote(class, sec ) 
	-- начинаем серию трейдов
	if (teststarted==false) then
		teststarted=true;
		message("SyncTradesTest.lua starting");
		Print("SyncTradesTest.lua starting...");
		StartSeries(trades_limit);   -- запускаем счетчики транзакций и времени
		start=os.clock();			  -- время старта
		Buy()
	end
end

-- покупка инструмента
function Buy()
	transIDstart=transIDstart+1
    TRANS_ID = transIDstart
	Print((tradecounter+1)..". Buy".." TRANS_ID="..TRANS_ID)
   -- Заполняет структуру для отправки транзакции на покупку 1 лота 
    local Transaction={
      ["TRANS_ID"]   = tostring(TRANS_ID),
      ["ACTION"]     = "NEW_ORDER",
      ["CLASSCODE"]  = CLASS_CODE_FUT,
      ["SECCODE"]    = SEC_CODE_FUT_FOR_OPEN,
      ["OPERATION"]  = "B", -- покупка (BUY)
      ["TYPE"]       = "M", -- по рынку (MARKET)
      ["QUANTITY"]   = "1", -- количество
      ["ACCOUNT"]    = TRADE_ACC,
      ["PRICE"]      = tostring(getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "offer").param_value + 30*getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "SEC_PRICE_STEP").param_value), -- по цене, завышенной на 30 мин. шагов цены
      ["COMMENT"]    = string.format("Trade #d Buy %s at %s",(tradecounter+1),SEC_CODE_FUT_FOR_OPEN,os.date("%Y.%m.%d %H:%M:%S"))
    }
    -- для протокола, по какой цене будем покупать
        local price=getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "offer").param_value
    --message("Offer Price="..price)
    -- время отправки торговой транзакции на сервер
	topen_start=os.clock();  -- момент покупки
	last_operation=BUY
    local Result = sendTransaction(Transaction);
    -- проверим, всё ли правильно
	if Result ~= "" then
		message("Покупка не удалось!\nОШИБКА: "..tostring(Result));
    end;    
end

-- продажа инструмента
function Sell()
	transIDstart=transIDstart+1
    TRANS_ID = transIDstart
	Print((tradecounter+1)..". Sell".." TRANS_ID="..TRANS_ID)
   -- Заполняет структуру для отправки транзакции на покупку 1 лота 
    local Transaction={
      ["TRANS_ID"]   = tostring(TRANS_ID),
      ["ACTION"]     = "NEW_ORDER",
      ["CLASSCODE"]  = CLASS_CODE_FUT,
      ["SECCODE"]    = SEC_CODE_FUT_FOR_OPEN,
      ["OPERATION"]  = "S", -- покупка (BUY)
      ["TYPE"]       = "M", -- по рынку (MARKET)
      ["QUANTITY"]   = "1", -- количество
      ["ACCOUNT"]    = TRADE_ACC,
      ["PRICE"]      = tostring(getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "bid").param_value - 30*getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "SEC_PRICE_STEP").param_value), -- по цене, завышенной на 30 мин. шагов цены
      ["COMMENT"]    = string.format("Trade #d Sell %s at %s",(tradecounter+1),SEC_CODE_FUT_FOR_OPEN,os.date("%Y.%m.%d %H:%M:%S"))
    }
    -- для протокола, по какой цене будем продавать
	local price=getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "bid").param_value
    --message("Bid Price="..price)
    -- время отправки торговой транзакции на сервер
	tclose_start=os.clock();  -- момент продажи
	last_operation=SELL	
    local Result = sendTransaction(Transaction);
    -- проверим, всё ли правильно
	if Result ~= "" then
		message("Продажа не удалось!\nОШИБКА: "..tostring(Result));
    end;    
end

--
function sendOrderTP_SL()
	transIDstart=transIDstart+1
    TRANS_ID = transIDstart
	Print((tradecounter+1)..". Send TP&SL".." TRANS_ID="..TRANS_ID)
	
    -- для протокола, по какой цене будем продавать
	local price=getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "bid").param_value
    --message("Bid Price="..price)
	priceStop = tostring(math.floor(getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, 'PRICEMAX').param_value)); -- Цена выставляемой заявки после страбатывания Стопа максимально возможная, чтобы не проскользнуло
	-- Заполняет структуру для отправки транзакции на покупку 1 лота 
    local Transaction={
		["TRANS_ID"]   = tostring(TRANS_ID),
		["ACTION"]     = "NEW_ORDER",
		["CLASSCODE"]  = CLASS_CODE_FUT,
		["SECCODE"]    = SEC_CODE_FUT_FOR_OPEN,
		["ACCOUNT"]    = TRADE_ACC,		
		["QUANTITY"] = "1",
		["STOP_ORDER_KIND"] = "TAKE_PROFIT_AND_STOP_LIMIT_ORDER",
		["OPERATION"] = "S", -- для коротких позиций "B" - покупка(BUY), для длинных - "S" продажа(SELL))
		["STOPPRICE"] = tostring(price+200), --цена активации тейк профита
		["OFFSET"] = "50",
		["OFFSET_UNITS"] = "PRICE_UNITS",
		["MARKET_TAKE_PROFIT"] = "YES",
		["PRICE"] = priceStop,
		["STOPPRICE2"] = tostring(price-200), --стоп цена
		["IS_ACTIVE_IN_TIME"] = "YES",
		["ACTIVE_FROM_TIME"] = "100000",   -- Часы:Минуты:Секунды
		["ACTIVE_TO_TIME"] = "234545",     -- Часы:Минуты:Секунды
		["MARKET_STOP_LIMIT"] = "YES",
		["COMMENT"]    = string.format("Trade #d Set TP&SL for %s at %s",(tradecounter+1),SEC_CODE_FUT_FOR_OPEN,os.date("%Y.%m.%d %H:%M:%S"))
    }
    -- время отправки торговой транзакции на сервер
	torder_start=os.clock();  -- момент отправки условной заявки
	last_operation=SETORDER	
    local Result = sendTransaction(Transaction);
    -- проверим, всё ли правильно
	if Result ~= "" then
		message("Установка заявки TP&SL не удалась!\nОШИБКА: "..tostring(Result));
    end;
end;

-- удаление отложенной заявки
function DeleteOrder()
	--transIDstart=transIDstart+1
	TRANS_ID = lastTPSL_trans_id -- transIDstart
	Print((tradecounter+1)..". Delete TP&SL #"..lastorderTPSL.." TRANS_ID="..TRANS_ID)
	-- Заполняет структуру для снятия заявки транзакции 
    local Transaction={
		["TRANS_ID"]   = tostring(TRANS_ID),
		["ACTION"]     = "KILL_ORDER",
		["CLASSCODE"]  = CLASS_CODE_FUT,
		["SECCODE"]    = SEC_CODE_FUT_FOR_OPEN,
		["ACCOUNT"]    = TRADE_ACC,		
		["ORDER_KEY"] = tostring(lastorderTPSL),
		["COMMENT"]    = string.format("Trade #d Delete order %d at %s",(tradecounter+1),lastorderTPSL,os.date("%Y.%m.%d %H:%M:%S"))
    }
    -- время отправки торговой транзакции на сервер
	tdelete_start=os.clock();  -- момент отправки приказа на удаление условной заявки 
	last_operation=DELETEORDER	
    local Result = sendTransaction(Transaction);
    -- проверим, всё ли правильно
	if Result ~= "" then
		message("Удаление заявки заявки TP&SL #"..lastorderTPSL.." не удалось!\nОШИБКА: "..tostring(Result));
    end;
end;

-- инициируем счетчики
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

-- вызывается при получении новой стоп-заявки или при изменении параметров существующей стоп-заявки
function OnTrade(order)
    --Print(tradecounter..". OnTrade #"..order.order_num.." Flags="..order.flags..order.system_ref) 
	-- обрабатываем события только последней транзакции
	if(order.trans_id~=TRANS_ID) then	
		return -- остальные события (отставшие, например) пропускаем, так как они ломают логику работы
	end
	-- событие может приходить 3 раза, обрабатываем только первый вызов
	curr_ontrade_event=order.trans_id..order.order_num
	if (curr_ontrade_event~=ontrade_event) then
		ontrade_event=curr_ontrade_event
		-- проверим текущее состояние автомата
		state=CheckState(order, nil, nil);
		--Print("state="..tostring(state));
		-- обработать состояние автомата
		ProcessState(state)
	end
end

-- вызывается при получении ответа на транзакцию пользователя, отправленную с помощью Trans2quik.dll, QPILE, QLua 
function OnTransReply(trans_reply)
	-- обрабатываем события только последней транзакции
	if(trans_reply.trans_id~=TRANS_ID) then	
		return -- остальные события (отставшие, например) пропускаем, так как они ломают логику работы
	end
    state=CheckState(nil, trans_reply, nil)
	-- обработать состояние автомата
	--ProcessState(state)	
end

-- вызывается терминалом QUIK при получении новой заявки или при изменении параметров существующей заявки
function OnOrder(order)
	-- обрабатываем события только последней транзакции
	if(order.trans_id~=TRANS_ID) then	
		return -- остальные события (отставшие, например) пропускаем, так как они ломают логику работы
	end
	-- событие может приходить 3 раза, обрабатываем только первый вызов
	curr_onorder_event=order.trans_id..order.order_num
	if (curr_onorder_event~=onorder_event) then
	    onorder_event=curr_onorder_event
		state=CheckState(nil, nil, order)
		-- обработать состояние автомата
		ProcessState(state)		
	end
end


-- выполнение действий в соответствии с состоянием автомата
function ProcessState(currstate)
	-- перебор состояний автомата
	if(currstate==startSeries) then -- тестирование началось - произведена первая покупка	
		start=os.clock();			-- время старта
		Buy();                  	-- проводим покупку
	end;
	if(currstate==buyDone)  then  	-- открылась длинная позиция
         Sell(); 			   		-- закрыть позицию // отправка заявки "Take Profit и Stop Limit"
	end;
	if(currstate==deleteDone) then	-- удалили условную заявку, можно открывать новую позицию
         Buy();         			-- покупка по рынку
	end;
	if(currstate==setDone) then     -- прошла установка SL и TP
         Sell();    	   			-- закрыть позицию
	end;
	if(currstate==sellDone) then	-- закрыта позиция, поэтому удаляем условную заявку "Take Profit и Stop Limit"
         Buy();						-- покупка по рынку
	end;
	if(currstate==seriesDone) then  -- закрылась последняя из TradeSeries позиций 
		finish=os.clock();  	-- время заверешения 
		delta=(finish-start)*1000;
		Print(string.format("Total time=%.1f ms",delta));
		Print(string.format("Average time: Open=%.1f ms, Close %.1f ms (%d series)",
                     timeOpen*1000/tradecounter,timeClose*1000/tradecounter,tradecounter));
		final_msg=string.format("Total series=%d, total time=%.1f ms",tradecounter,delta)
		final_msg=final_msg.."\n"..string.format("Average time: open=%.1f ms, close %.1f ms (%d series)",
                     timeOpen*1000/tradecounter,timeClose*1000/tradecounter,tradecounter)
		message(final_msg);
		-- установим флаг в положение 'Выкл'
		--running = false
		--Print("finishing...");		
	end
	--info=getOnTradeStructure(order,tradecounter);
	--logfile:write(info);
end

-- проверка состояния
function CheckState(orderfromOnTrade, transfromOnTransreply, orderfromOnOrder)
    temp_state=noChanges
    -- обработка вызова из OnTransReply	
	if (transfromOnTransreply~=nil) then	
		TransID=transfromOnTransreply.trans_id	-- id транзакции
		Flags=transfromOnTransreply.flags
		lastorder_ticket=transfromOnTransreply.order_num
		-- получим статус заявки
		status=getSatus(transfromOnTransreply.status)
		-- выведем в лог
		Print(string.format("OnTransReply: TransID=%d  %s Flags=%d",TransID,status,Flags))
	end

    -- обработка вызова из OnTrade
	if (orderfromOnTrade~=nil) then
		-- заявка выполнена, появилась сделка в торговой системе
		stringdeal=tostring(orderfromOnTrade.trade_num)
		order=orderfromOnTrade.order_num		-- тикет ордера
		TransID=orderfromOnTrade.trans_id		-- id транзакции
		Flags=orderfromOnTrade.flags
		-- выведем в лог
		Print(string.format("OnTrade: TransID=%d Order_num=%s  Flags=%d",TransID,order,Flags))
		--Print(string.format("%d. TransID=%d order #%s %s %s",(tradecounter+1),TransID, order,last_operation,stringdeal))
		return (noChanges) -- 
	end
    
    -- обработка вызова из OnOrder		
	if (orderfromOnOrder~=nil) then	
		order=orderfromOnOrder.order_num		-- тикет ордера
		TransID=orderfromOnOrder.trans_id		-- id транзакции
		Flags=orderfromOnOrder.flags
		-- выведем в лог
		Print(string.format("OnOrder: TransID=%d Order_num=%s  Flags=%d",TransID,order,Flags))
		
		-- последняя транзакция была на покупку		
		if ((orderfromOnOrder.order_num==lastorder_ticket)and(last_operation==BUY)and(orderfromOnOrder.trade_num~=0)) then 
			topen_finish=os.clock()
			timeOpen=timeOpen+(topen_finish-topen_start)
			lastorder_ticket=0
			last_operation="No"
			Print(string.format("%d. Open time=%.1f ms",(tradecounter+1),(topen_finish-topen_start)*1000))
			-- выполнена покупка 
            Print("Возвращаем из CheckState state=buyDone")
			return (buyDone)
		end			
		
		-- последняя транзакция была на продажу
		if ((orderfromOnOrder.order_num==lastorder_ticket)and(last_operation==SELL)and(orderfromOnOrder.trade_num~=0)) then 
			tclose_finish=os.clock()
			timeClose=timeClose+(tclose_finish-tclose_start)		
			lastorder_ticket=0
			last_operation="No"
			Print(string.format("%d. Close time=%.1f ms",(tradecounter+1),(tclose_finish-tclose_start)*1000))
			-- выполнена продажа 
			tradecounter=tradecounter+1
			-- серия трейдов заверешена
			if(tradecounter>=trades_limit) then
				return(seriesDone) -- завершаем тестирование
			end			
			return (sellDone)
		end	
		-- последняя транзакция была условная заявка "TAKE_PROFIT_AND_STOP_LIMIT_ORDER"
		if ((orderfromOnOrder.order_num==lastorder_ticket)and(last_operation==SETORDER)) then 
			torder_finish=os.clock()
			timeSet=timeSet+(torder_finish-torder_start)
			lastorderTPSL=orderfromOnOrder.order_num
			lastTPSL_trans_id=orderfromOnOrder.trans_id
			lastorder_ticket=0
			last_operation="No"
			Print(string.format("%d. SetOrder time=%.1f ms",(tradecounter+1),(torder_finish-torder_start)*1000))
			-- установлена условная заявка "TAKE_PROFIT_AND_STOP_LIMIT_ORDER"
			return (setDone) 
		end

		-- последняя транзакция была "KILL_ORDER"
		if ((orderfromOnOrder.order_num==lastorder_ticket)and(last_operation==DELETEORDER)) then 
			tdelete_finish=os.clock()
			timeDelete=timeDelete+(tdelete_finish-tdelete_start)
			lastorder_ticket=0
			last_operation="No"
			Print(string.format("%d. DeleteOrder time=%.1f ms",(tradecounter+1),(tdelete_finish-tdelete_start)*1000))
			tradecounter=tradecounter+1
			-- серия трейдов заверешена
			if(tradecounter>=trades_limit) then
				return(seriesDone) -- завершаем тестирование
			end
			-- сняли условную заявку "TAKE_PROFIT_AND_STOP_LIMIT_ORDER"
			return (deleteDone) 
		end					
	end		
	Print("Возвращаем из CheckState state="..temp_state)
	return (temp_state)
end


-- событие остановки скрипта пользователем
function OnStop(s)
	-- установим флаг в положение 'Выкл'
	running = false
	Print("SyncTradesTest.lua finishing...");
	return 3000 -- задается таймаут в 3 секунды
end

function Print(line)
	if (logfile~=nil) then
	    timestamp=os.date("%Y.%m.%d %H:%M:%S ");
		logfile:write(timestamp.."\t"..line.."\n");
	end
end

function getSatus(statuscode)
	status_string="Неизвестный статус "..statuscode
	if (statuscode==0) then
		status_string="Tранзакция отправлена серверу"
	end
	if (statuscode==1) then
		status_string="Транзакция получена на сервер QUIK от клиента"
	end
	if (statuscode==2) then
		status_string="Ошибка при передаче транзакции в торговую систему"
	end
	if (statuscode==3) then
		status_string="Tранзакция выполнена"
	end
	if (statuscode==4) then
		status_string="Tранзакция не выполнена торговой системой"
	end
	if (statuscode==5) then
		status_string="Tранзакция не прошла проверку сервера QUIK по каким-либо критериям"
	end
	if (statuscode==6) then
		status_string="Tранзакция не прошла проверку лимитов сервера QUIK"
	end
	if (statuscode==10) then
		status_string="Транзакция не поддерживается торговой системой"
	end
	if (statuscode==11) then
		status_string="Транзакция не прошла проверку правильности электронной цифровой подписи"
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
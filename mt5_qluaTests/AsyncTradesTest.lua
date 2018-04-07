-- AsyncTradesTest.lua
running = true                	-- Флаг работы скрипта
TRADE_ACC="4100R24"       	    -- Торговый счет на торговом сервер QUIK
CLASS_CODE_FUT="SPBFUT"       	-- Класс ФЬЮЧЕРСОВ
SEC_CODE_FUT_FOR_OPEN="SiU6"  	-- Код бумаги (фьючерса)
TRANS_ID=0                    	-- Идентификатор транзакции, задаваемый пользователем при отравке из QLUA
-- 
local logfile = 0 				-- Файл для записи логов
local start_test,finish_test;	-- начало и конец теста
local transIDstart				-- начальный номер транзакций задается по номеру минуты и секунде
local tradecounter              -- счетчик проведенных трейдов

resultinfo=""
running=true
finished=false
tickcounter=0
-- это главная функция скрипта, запускается автоматически и скрипт работает пока она не завершена 
function main()
	-- Пытается открыть файл в режиме "чтения/записи"
	logfile = io.open(getScriptPath().."\\AsyncTradesTest_log.txt","a+");
	-- Если файл не существует
	if logfile == nil then 
		-- Создает файл в режиме "записи"
		logfile = io.open(getScriptPath().."\\AsyncTradesTest_log.txt","w"); 
		-- Закрывает файл
		logfile:close();
		-- Открывает уже существующий файл в режиме "чтения/записи"
		logfile = io.open(getScriptPath().."\\AsyncTradesTest_log.txt","r+");
	end;
	-- зададим номер первой транзакции
	minutes=os.date("%M")
	seconds=os.date("%S")
	transIDstart=minutes*10000+seconds*100	
	Print("AsyncTradesTest.lua starting...");	
	tradecounter=0
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
      ["PRICE"]      = tostring(getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "offer").param_value + 30*getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "SEC_PRICE_STEP").param_value), -- по цене, завышенной на 10 мин. шагов цены
      ["COMMENT"]    = "Test"
    }	
	tradecounter=0;
	-- запомним время старта
	start_test=os.clock()
	-- запускаем серию из 10-ти покупок
	for trade = 1, 10, 1 do
        -- Buy() заменим на прямой вызов 
		tradecounter=tradecounter+1;
		transIDstart=transIDstart+1
		TRANS_ID = transIDstart		
		Transaction["TRANS_ID"]=tostring(TRANS_ID);
		Transaction["COMMENT"]=tostring(tradecounter);
		local Result = sendTransaction(Transaction);
		-- проверим результат отправки
		if Result ~= "" then
			message("Покупка не удалось!\nОШИБКА: "..tostring(Result));	
		end; 
	    Print((tradecounter)..". Buy 1 lot "..SEC_CODE_FUT_FOR_OPEN.." TRANS_ID="..TRANS_ID)   		
    end
	-- тест завершен
	finish_test=os.clock()
	fulltime=(finish_test-start_test)*1000.
	finished=true
	info=string.format("Total time=%.1f ms",fulltime)
	Print(info)
	info=string.format("Average time=%.2f ms (%d series)",fulltime/tradecounter,tradecounter)
	Print(info)
	resultinfo=string.format("Average time=%.2f ms (%d series)",fulltime/tradecounter, tradecounter)	
	Print("AsyncTradesTest.lua finishing...");	
	-- флаг остановки скрипта 
    while running do
        sleep(1000)
    end
    -- сбрасываем файл
	logfile:flush();
	logfile:close();	
end

-- вызывается при каждом обновлении стакана котировок
function OnQuote(class, sec ) 
	-- соорудим таймер по количеству пришедших тиков для остановки скрипта после завершения торговых операций
	if (finished) then             -- если серия торговых операций завершена
		tickcounter=tickcounter+1; -- то начинаем считать обновления стакана
		if(tickcounter>5) then     -- после пятого тика в стакане завершаем работу
			message(resultinfo);   -- но сначала выведем результаты тестирования
			running=false          -- стоп машина
		end	
	end
end

-- событие остановки скрипта пользователем
function OnStop(s)
	-- установим флаг в положение 'Выкл'
	running = false
	Print("finishing...");
	message(resultinfo)
	return 3000 -- задается таймаут в 3 секунды
end

function Print(line)
	if (logfile~=nil) then
	    timestamp=os.date("%Y.%m.%d %H:%M:%S ");
		logfile:write(timestamp.."\t"..line.."\n");
	end
end
-- покупка инструмента
function Buy()
	transIDstart=transIDstart+1
    TRANS_ID = transIDstart
	tradecounter=tradecounter+1
	Print((tradecounter)..". Buy 1 lot "..SEC_CODE_FUT_FOR_OPEN.." TRANS_ID="..TRANS_ID)
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
      ["PRICE"]      = tostring(getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "offer").param_value + 30*getParamEx(CLASS_CODE_FUT, SEC_CODE_FUT_FOR_OPEN, "SEC_PRICE_STEP").param_value), -- по цене, завышенной на 10 мин. шагов цены
      ["COMMENT"]    = string.format("Trade #d Buy %s at %s",(tradecounter),SEC_CODE_FUT_FOR_OPEN,os.date("%Y.%m.%d %H:%M:%S"))
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

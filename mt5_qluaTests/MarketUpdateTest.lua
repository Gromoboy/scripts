-- Счетчик обновлений стакана MarketUpdateTest.lua
CLASS_CODE_FUT="SPBFUT"       	-- Класс ФЬЮЧЕРСОВ
SEC_CODE_FUT_FOR_OPEN="SiU6"  	-- Код бумаги (фьючерса)
running = true                	-- Флаг работы скрипта
local logfile;
local ticks=0;
local start_ticks=5;  	-- сколько тиков должно пройти за секунду, чтобы отсчет времени начался
local lastupdate;		-- время последнего обновления стакана
-- массивы для хранения тиков, 5000 хватит на 1 минуту с головой
local ticks={};        	-- номера тиков
local ticktimes={};  	-- время тика в миллисекундах
local tickcounter=0;	-- счетчик тиков
local startsession=0;	-- время начала торговой сессии
local firsttick=0;		-- номер первого тика в стакане
local prevupdate=0;     -- время последнего обновления стакана
-- стакан запущен
local marketstarted=false;
-- вспомогательный параметр для вычисления индекса в массиве ticktimes[]
local shift;
-- это главная функция скрипта, запускается автоматически и скрипт работает пока она не завершена 
function main()
	-- Пытается открыть файл в режиме "чтения/записи"
	logfile = io.open(getScriptPath().."\\MarketUpdateTest_log.txt","a+");
	-- Если файл не существует
	if logfile == nil then 
		-- Создает файл в режиме "записи"
		logfile = io.open(getScriptPath().."\\MarketUpdateTest_log.txt","w"); 
		-- Закрывает файл
		logfile:close();
		-- Открывает уже существующий файл в режиме "чтения/записи"
		logfile = io.open(getScriptPath().."\\MarketUpdateTest_log.txt","r+");
	end;
	shift=start_ticks-1;
	Print("MarketUpdateTest.lua starting...");
	message("MarketUpdateTest.lua starting");
	Print("CLASS_CODE_FUT="..CLASS_CODE_FUT..":    SEC_CODE_FUT_FOR_OPEN="..SEC_CODE_FUT_FOR_OPEN);
	-- флаг переключается только при остановки скрипта пользователем
    while running do
		--message(os.date()) --раз в 15 секунд выводит текущие дату и время
        sleep(5000)
    end
	logfile:flush();
	logfile:close();
end

-- вызывается при каждом обновлении стакана котировок
function OnQuote(class, sec ) 
	--Print("OnQuote: "..class.."  "..sec);
	if(running==false) then
		return
	end

	-- отслеживаем только по нужному инструменту
	if class==CLASS_CODE_FUT and sec==SEC_CODE_FUT_FOR_OPEN then
		-- время обновления стакана в секундах с момента запуска терминала Quik (с точностью до миллисекунды)
		lastupdate=os.clock();
		-- считаем тики
		tickcounter=tickcounter+1;
		ticks[tickcounter]=tickcounter;
		ticktimes[tickcounter]=lastupdate;
        --Print(string.format("ticks #%d  os.clock()=%.3f",tickcounter,lastupdate));
		if marketstarted==false then
			Print(string.format("%d ticks (+%d ms)",tickcounter,(lastupdate-prevupdate)*1000));
			prevupdate=lastupdate;
			if tickcounter>=start_ticks then
				-- если start_ticks тиков пришли меньше чем за секунду 
				if lastupdate-ticktimes[tickcounter-shift]<1 then
					startsession=ticktimes[tickcounter-shift];
					firsttick=tickcounter-shift;
					marketstarted=true;
					Print("Time counting starts from tick #"..firsttick);				
				end
			end
		else
			local counted_ticks=tickcounter-firsttick+1;
			seconds=lastupdate-startsession;		
			info=string.format("%d ticks for %.1f seconds:  %.1f ticks/sec",
								counted_ticks,seconds,counted_ticks/seconds);
			message(info);
			info=info..string.format(" (+%d ms)",(lastupdate-prevupdate)*1000);
			Print(info);		
			prevupdate=lastupdate;
			-- скрипт остановится через минуту
			if seconds>30 then
				running=false;
			end			
		end
		
	end	
	-- если тиков набралось много, остановим принудительно скрипт
	if tickcounter>1000 then
		running=false;
	end

end

-- событие остановки скрипта пользователем
function OnStop(s)
	fulltime=lastupdate-start;
	info=string.format("MarketUpdateTest.lua finished, %d updates of Market for %.1f seconds = %.1f ticks/sec",
						ticks,fulltime,ticks/fulltime);
	Print(info);
	message(info);
	-- установим флаг в положение 'Выкл'
	running = false;
	return 3000 -- задается таймаут в 3 секунды
end



-- выводит сообщения в лог-файл
function Print(line)
	if (logfile~=nil) then
	    timestamp=os.date("%Y.%m.%d %H:%M:%S ");
		logfile:write(timestamp.."\t"..line.."\n");
	end
end
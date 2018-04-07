dofile(getScriptPath().."\\hacktrade.lua")
dofile(getScriptPath().."\\basicQTable.lua")

function Robot()
   optionClassCode = "OPTW"--SPBOPT"
   baseClassCode = "SPBFUT"
   baseCode = "RIH8"
   lastClick ={
      row = 1,
      col = 1
   }
   qtable = basicQTable.new{
      rows=9, columns=5, title="Опционая условная заявка", width = 16
   }
   cells = qtable.cells
   QColor = qtable.QColor
   isTrading = false
   tradingSize=0

   qtable:AddCell{name = "baseSec",         row = 1, column = 1}
   qtable:AddCell{name = "recalc",          row = 1, column = 2}
   qtable:AddCell{name = "selected",        row = 1, column = 4}
   qtable:AddCell{name = "expireDate",      row = 1, column = 5}
   qtable:AddCell{name = "theorPrice",      row = 2, column = 4} 

   qtable:AddCell{name = "highStrikeCall",  row = 3, column = 2}
   qtable:AddCell{name = "highStrikePut",   row = 3, column = 3}
   qtable:AddCell{name = "centrStrikeCall", row = 4, column = 2}
   qtable:AddCell{name = "centrStrikePut",  row = 4, column = 3}
   qtable:AddCell{name = "lowStrikeCall",   row = 5, column = 2}
   qtable:AddCell{name = "lowStrikePut",    row = 5, column = 3}

   qtable:AddCell{name = "priceType",       row = 7, column = 3}
   
   qtable:AddCell{name = "basePraceMonitor",row = 7, column = 1}
   qtable:AddCell{name = "condSign",        row = 8, column = 1}
   qtable:AddCell{name = "basePrice",       row = 9, column = 1}

   qtable:AddCell{name = "quantity",        row = 7, column = 2}
   qtable:AddCell{name = "startStop",       row = 9, column = 2}

   qtable:AddCell{name = "highStrike",      row = 3, column = 1}
   qtable:AddCell{name = "centrStrike",     row = 4, column = 1}
   qtable:AddCell{name = "lowStrike",       row = 5, column = 1}
   
   local basePrice = getParamEx(baseClassCode, baseCode, "last").param_value
   qtable.cells.basePrice.SetNumber( basePrice )

   local centrStrike = math.floor( tonumber(basePrice)/2500 + 0.5 ) * 2500
   qtable.cells.centrStrike.SetNumber( centrStrike )
   qtable.cells.highStrike.SetNumber(  centrStrike + 2500 )
   qtable.cells.lowStrike.SetNumber(   centrStrike - 2500 )
   cells.baseSec.SetText(baseCode)
   cells.condSign.SetText(">")
   cells.priceType.SetText("LAST price")

   cells.startStop.SetText("START")
   cells.selected.SetText("")
   cells.quantity.SetText("0")
   cells.basePraceMonitor.SetText("0")
      
   qtable.cells.baseSec.SetColor{
      selectedBackground = QColor.black, selectedForeground = QColor.white
   }
   qtable.cells.basePrice.SetColor{
      selectedBackground = QColor.black, selectedForeground = QColor.white
   }
   qtable.cells.quantity.SetColor{
      selectedBackground = QColor.black, selectedForeground = QColor.white
   }
   qtable.cells.highStrikeCall.SetColor{
      background = QColor.green, foreground = QColor.black
   }
   qtable.cells.highStrikePut.SetColor{
      background = QColor.red, foreground = QColor.black
   }
   qtable.cells.centrStrikeCall.SetColor{
      background = QColor.green, foreground = QColor.black
   }
   qtable.cells.centrStrikePut.SetColor{
      background = QColor.red, foreground = QColor.black
   }
   qtable.cells.lowStrikeCall.SetColor{
      background = QColor.green, foreground = QColor.black
   }
   qtable.cells.lowStrikePut.SetColor{
      background = QColor.red, foreground = QColor.black
   }

   qtable:SetOnEvent(eventHandler)
   qtable:SetWinPos{dy = 200, dx = 500}


   feedBase = MarketData{
      market= baseClassCode,
      ticker= baseCode
   }

   feedOptn = MarketData{
      market= optionClassCode,
      ticker= ""
   }
   
   tradingCode = "SPBFUT00T48"
   order = SmartOrder {
      account = tradingCode,
      clien   = tradingCode,
      market  = optionClassCode,
      ticker  = "",
    }

    ind = Indicator{
        tag=""
    }
    

   while true do
      condPrice =  cells.basePrice.GetNumber()
      
      lastPrice = getParamEx(baseClassCode, baseCode, "last").param_value
      lastPrice = tonumber(lastPrice)
      cells.basePraceMonitor.SetNumber(lastPrice)
      if cells.selected.GetText() ~= "" then 
         theorPrice = getParamEx(optionClassCode, cells.selected.GetText(), "theorprice").param_value
         cells.theorPrice.SetNumber(theorPrice)
      end
      --message(tostring(condPrice))
      --message(tostring(lastPrice))
      if isTrading then

         if cells.condSign.GetText() == ">"then
            if lastPrice > condPrice then
               repeat
                  if cells.quantity.GetNumber() >= 1 then 
                     buyPrice = feedOptn.theorprice - 100
                     if buyPrice <= 0 then buyPrice = 10 end
                  elseif cells.quantity.GetNumber() <= -1 then
                     buyPrice = feedOptn.theorprice + 100
                  else
                     buyPrice = 0
                  end
                  order:update( buyPrice, cells.quantity.GetNumber() )
                  message(tostring(cells.quantity.GetNumber()).." ticker = "..order.ticker.." buyPrice= "..tostring(buyPrice))
                  Trade()
                  sleep(500)
               until order.filled
            end
         else
            if lastPrice < condPrice then
               repeat
                  if cells.quantity.GetNumber() >= 1 then 
                     buyPrice = feedOptn.theorPrice - 100
                     if buyPrice <= 0 then buyPrice = 10 end
                  elseif cells.quantity.GetNumber() <= -1 then
                        buyPrice = feedOptn.theorprice + 100
                  else
                     buyPrice = 0
                  end
                  order:update( buyPrice, cells.quantity.GetNumber() )
                  message(tostring(cells.quantity.GetNumber()).."ticker = "..order.ticker.." buyPrice= "..tostring(buyPrice))
                  Trade()
                  sleep(500)
               until order.filled
            end
         end

      end
      Trade()
      sleep(500)
   end
end




function eventHandler( t_id, msg, par1, par2 )

   if msg == QTABLE_LBUTTONDOWN  then
      --SetColor(t_id,lastClick.row, lastClick.col, QTABLE_DEFAULT_COLOR,QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR,QTABLE_DEFAULT_COLOR)
      lastClick.row = par1
      lastClick.col = par2
      --SetColor(t_id,par1, par2, RGB(100,250,100),RGB(0,0,0), QTABLE_DEFAULT_COLOR,QTABLE_DEFAULT_COLOR)

      -- Выбор опциона
      if lastClick.row == cells.highStrikeCall.row and 
         lastClick.col == cells.highStrikeCall.col then

         order.ticker    = cells.highStrikeCall.GetText()
         feedOptn.ticker = cells.highStrikeCall.GetText()

         cells.selected.SetText(cells.highStrikeCall.GetText() )
         cells.selected.SetColor{background = QColor.green}
         cells.expireDate.SetText(getParamEx(optionClassCode, cells.highStrikeCall.GetText(), "EXPDATE").param_image)
      end
      if lastClick.row == cells.highStrikePut.row and 
         lastClick.col == cells.highStrikePut.col then 

         order.ticker    = cells.highStrikePut.GetText()
         feedOptn.ticker = cells.highStrikePut.GetText()

         cells.selected.SetText(qtable.cells.highStrikePut.GetText() )
         cells.selected.SetColor{background = QColor.red}
         cells.expireDate.SetText(getParamEx(optionClassCode, cells.highStrikePut.GetText(), "EXPDATE").param_image)
      end
      if lastClick.row == cells.centrStrikeCall.row and 
         lastClick.col == cells.centrStrikeCall.col then 

         order.ticker    = cells.centrStrikeCall.GetText()
         feedOptn.ticker = cells.centrStrikeCall.GetText()

         cells.selected.SetText(qtable.cells.centrStrikeCall.GetText() )
         cells.selected.SetColor{background = QColor.green}
         cells.expireDate.SetText(getParamEx(optionClassCode, cells.centrStrikeCall.GetText(), "EXPDATE").param_image)
      end
      if lastClick.row == cells.centrStrikePut.row and 
         lastClick.col == cells.centrStrikePut.col then 

         order.ticker    = cells.centrStrikePut.GetText()
         feedOptn.ticker = cells.centrStrikePut.GetText()

         cells.selected.SetText(qtable.cells.centrStrikePut.GetText() )
         cells.selected.SetColor{background = QColor.red}
         cells.expireDate.SetText(getParamEx(optionClassCode, cells.centrStrikePut.GetText(), "EXPDATE").param_image)
      end
      if lastClick.row == cells.lowStrikeCall.row and
         lastClick.col == cells.lowStrikeCall.col then 

         order.ticker    = cells.lowStrikeCall.GetText()
         feedOptn.ticker = cells.lowStrikeCall.GetText()

         cells.selected.SetText(qtable.cells.lowStrikeCall.GetText() )
         cells.selected.SetColor{background = QColor.green}
         cells.expireDate.SetText(getParamEx(optionClassCode, cells.lowStrikeCall.GetText(), "EXPDATE").param_image)
      end
      if lastClick.row == cells.lowStrikePut.row and 
         lastClick.col == cells.lowStrikePut.col then 

         order.ticker    = cells.lowStrikePut.GetText()
         feedOptn.ticker = cells.lowStrikePut.GetText()

         cells.selected.SetText(qtable.cells.lowStrikePut.GetText() )
         cells.selected.SetColor{background = QColor.red}
         cells.expireDate.SetText(getParamEx(optionClassCode, cells.lowStrikePut.GetText(), "EXPDATE").param_image)
      end
      -- Знак условия (больше или меньше)
      if lastClick.row == qtable.cells.condSign.row and lastClick.col == qtable.cells.condSign.col then 
         if qtable.cells.condSign.GetText() == ">" then 
            qtable.cells.condSign.SetText("<")
         else  
            qtable.cells.condSign.SetText(">")
         end
      end
      -- Тип цены (цена закрытия свечи или цена последней сделки)
      if lastClick.row == qtable.cells.priceType.row and 
         lastClick.col == qtable.cells.priceType.col then

         if qtable.cells.priceType.GetText() == "LAST price" then
            qtable.cells.priceType.SetText("CLOSE price")
         else
            qtable.cells.priceType.SetText("LAST price")
         end
      end
  
      -- Запуск (или остановка) заявки
      if lastClick.row == qtable.cells.startStop.row and 
         lastClick.col == qtable.cells.startStop.col then

         if qtable.cells.startStop.GetText() == "START" then
            isTrading = true
            qtable.cells.startStop.SetText("STOP")
            qtable.cells.startStop.SetColor{background = QColor.red, foreground = QColor.black}
         else
            isTrading = false
            qtable.cells.startStop.SetText("START")
            qtable.cells.startStop.SetColor{background = QColor.green, foreground = QColor.black}
         end
      end      
      -- Пересчитать страйки ближайших опционов по заданному базовому активу и выводит 3 пута и 3 кола
      if lastClick.row == qtable.cells.recalc.row and 
         lastClick.col == qtable.cells.recalc.col then

         local basePrice = getParamEx(baseClassCode, baseCode, "last").param_value
         local centrStrike = math.floor( basePrice/2500 + 0.5 ) * 2500
         local highStrike  = centrStrike + 2500
         local lowStrike   = centrStrike - 2500
         local optionsList = getClassSecurities(optionClassCode)
         
         local optionCall, optionPut = getNearestOptionsFromString{
            optionsCsvString = optionsList, strike = centrStrike
         }
         cells.centrStrikeCall.SetText(optionCall)
         cells.centrStrikePut.SetText(optionPut)

         optionCall, optionPut = getNearestOptionsFromString{
            optionsCsvString = optionsList, strike = highStrike
         }
         cells.highStrikeCall.SetText(optionCall)
         cells.highStrikePut.SetText(optionPut)

         optionCall, optionPut = getNearestOptionsFromString{
            optionsCsvString = optionsList, strike = lowStrike
         }
         cells.lowStrikeCall.SetText(optionCall)
         cells.lowStrikePut.SetText(optionPut)
      end
   end

   if msg == QTABLE_VKEY then
      local isDigit = par2>=48 and par2<=57
      local isLetter = par2>=65 and par2<=90
      local isBackspace = par2==8
      local isLeftArrow = par2 == 37
      local isRightArrow = par2 == 39

      local cell = qtable.cells.baseSec

      if lastClick.row == cell.row and lastClick.col == cell.col then

         if isDigit or isLetter  then
            local text = cell.GetText()
            if string.len( text ) < 4 then
               text = text..string.char( par2 )
               cell.SetText(text)
            end
         elseif(isBackspace) then
            cell.SetText("")
         end

         if isLeftArrow or isRightArrow then
            local letters = cell.GetText():sub(1,3)
            local digit   = cell.GetText():sub(4,4)
            
            if letters == "RIH" then 
               if isRightArrow then letters = "RIM"
               else
                  letters = "RIZ" 
                  digit = tonumber(digit)-1
                  if digit == -1 then digit = 9 end
               end
            elseif letters == "RIM" then letters = isRightArrow and "RIU" or "RIH"
            elseif letters == "RIU" then letters = isRightArrow and "RIZ" or "RIM"
            elseif letters == "RIZ" then 
               if isLeftArrow then letters = "RIU"
               else
                  letters = "RIH"
                  digit = tonumber(digit) + 1 
                  if digit == 10 then digit = 0 end
               end   
            end
            cell.SetText(letters..tostring(digit) )
         end
      end

      cell = qtable.cells.basePrice
      if lastClick.row == cell.row and lastClick.col == cell.col then
         
         if isDigit and string.len(cell.GetText() ) < 7 then
            if #cell.GetText() == 3 then
               cell.SetText(cell.GetText().." "..string.char(par2) )
            else
               cell.SetText(cell.GetText()..string.char(par2) )
            end
         elseif isBackspace then
            cell.SetText("")
         end

         if isRightArrow or isLeftArrow then
            cell.SetNumber(isRightArrow and cell.GetNumber()+10 or cell.GetNumber()-10)
         end
      end

      cell = qtable.cells.quantity
      if lastClick.row == cell.row and lastClick.col == cell.col then
         
         if isDigit then
            
            cell.SetText(cell.GetText()..string.char(par2))
   
         elseif isBackspace then
            cell.SetText("")
         end

         if isRightArrow or isLeftArrow then
            cell.SetNumber(isRightArrow and cell.GetNumber()+1 or cell.GetNumber()-1)
         end
      end

   end
end

function getNearestOptionsFromString( args )
   -- optionsCsvString, strike
   --def
   if type(args.strike) == "nil" or type(args.optionsCsvString) ~= "string" then
      message("getFirstTwoOptionsByStrikege function has wrong argument")
   end
   if type(args.strike) == "number" then args.strike = tostring(args.strike) end
   --end def
   local optionCall, optionPut
   local optWeekCode
   local countThursday = 0
   local count = 0
   local curTime = os.time()
   for i=1,os.date("*t", curTime).day do
      curTime = curTime - 24*60*60
      if os.date("*t", curTime).wday == 5 then countThursday = countThursday + 1 end
   end
 
   if countThursday == 0 then optWeekCode ="A"
   elseif countThursday == 1 then optWeekCode ="B"
   elseif countThursday == 3 then optWeekCode ="D"
   elseif countThursday == 4 then optWeekCode ="E" end
   --TODO доработать третью неделю(месячный опцион) и 5 неделю(будет ли в ней четверг)


   for word in string.gmatch( args.optionsCsvString, '([^,]+)' ) do
      if string.find(word, args.strike, 1, true) ~= nil then
         
         if word:sub(-1) == optWeekCode  then 
            if count == 0 then
               optionCall = word
               count = count + 1
            else 
               optionPut = word
               break
            end
         end
      end
   end
   --message(args.optionsCsvString)
   return optionCall, optionPut
end
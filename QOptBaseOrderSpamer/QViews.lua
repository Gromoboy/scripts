dofile(getScriptPath().."\\QOptBaseOrderSpamer\\QTableClass.lua")
dofile(getScriptPath().."\\QOptBaseOrderSpamer\\QTrade.lua")
--
CLIENT = "SPBFUT00154"--SPBFUT00T48
OptionBuyTable = QTableClass:new{
   baseClass = "SPBFUT",
   baseTicker = "RIH8",
   optionClass = "OPTW",--SPBOPT"
   order = QSmartOrder:new{
      account   = CLIENT,
      client    = CLIENT,
      price     = 0,
      planned   = 0,
      position  = 0,
      trans_id  = 0,
      doFillUp  = false,
   },
   doCheckCondition = false,
   isLog = true
}

function OptionBuyTable:Init()
   --message(tostring(self.baseTicker))
   self:CreateWindow{
      rows = 9, columns = 5, 
      title = "Опционная условная заявка 2", 
      colWidth = 16
   }
   self:SetWinPos{x = 600 , y = 400, dy = 300, dx = 600}

   self:AddCell{name = "baseSec",         row = 1, column = 1}
   self:AddCell{name = "recalc",          row = 1, column = 2}
   self:AddCell{name = "selected",        row = 1, column = 4}
   self:AddCell{name = "expireDate",      row = 1, column = 5}

   self:AddCell{name = "theorPrice",      row = 2, column = 4} 

   self:AddCell{name = "highStrikeCall",  row = 3, column = 2}
   self:AddCell{name = "highStrikePut",   row = 3, column = 3}

   self:AddCell{name = "centrStrikeCall", row = 4, column = 2}
   self:AddCell{name = "centrStrikePut",  row = 4, column = 3}

   self:AddCell{name = "lowStrikeCall",   row = 5, column = 2}
   self:AddCell{name = "lowStrikePut",    row = 5, column = 3}

   self:AddCell{name = "titleBPMon",      row = 6, column = 1}
   self:AddCell{name = "titleQnty",       row = 6, column = 2}

   self:AddCell{name = "basePriceMonitor",row = 7, column = 1}
   self:AddCell{name = "quantity",        row = 7, column = 2}
   self:AddCell{name = "priceType",       row = 7, column = 3}

   self:AddCell{name = "condSign",        row = 8, column = 1}

   self:AddCell{name = "basePrice",       row = 9, column = 1}
   self:AddCell{name = "startStop",       row = 9, column = 2}

   self:AddCell{name = "highStrike",      row = 3, column = 1}
   self:AddCell{name = "centrStrike",     row = 4, column = 1}
   self:AddCell{name = "lowStrike",       row = 5, column = 1}

   local cells = self.cells
   local qc    = self.QColor

   self:LoadTickers()

   self.feedBase = {
      classCode = self.baseClass,
      ticker    = self.baseTicker,
   }
   setmetatable(self.feedBase, MarketData)

   self.feedOptn = {
      classCode = self.optionClass,
      ticker    = ""
   }
   setmetatable(self.feedOptn, MarketData)

   cells.basePrice.SetValue( self.feedBase.last )

   cells.baseSec.SetValue(self.baseTicker)
   cells.condSign.SetValue(">")
   cells.priceType.SetValue("LAST price")
   cells.startStop.SetValue("START")
   cells.selected.SetValue("")
   cells.titleQnty.SetValue("quantity:")
   cells.quantity.SetValue(0)
   cells.titleBPMon.SetValue("curPrice:")
   cells.basePriceMonitor.SetValue(0)
   cells.highStrikePut.SetValue("")
   cells.highStrikeCall.SetValue("")
   cells.centrStrikePut.SetValue("")
   cells.centrStrikeCall.SetValue("")
   cells.lowStrikePut.SetValue("")
   cells.lowStrikeCall.SetValue("")
   
   

   cells.baseSec.SetColor{
      selectedBackground = qc.black, 
      selectedForeground = qc.white
   }
   cells.basePrice.SetColor{
      selectedBackground = qc.black, 
      selectedForeground = qc.white
   }
   cells.recalc.SetColor{
      background = qc.blue,
      foreground = qc.white
   }
   cells.startStop.SetColor{
      background = qc.blue,
      foreground = qc.white
   }
   cells.condSign.SetColor{
      background = qc.blue,
      foreground = qc.white
   }
   cells.quantity.SetColor{
      selectedBackground = qc.black, 
      selectedForeground = qc.white
   }
   cells.highStrikeCall.SetColor{
      background = qc.green, 
      foreground = qc.black
   }
   cells.highStrikePut.SetColor{
      background = qc.red, 
      foreground = qc.black
   }
   cells.centrStrikeCall.SetColor{
      background = qc.green, 
      foreground = qc.black
   }
   cells.centrStrikePut.SetColor{
      background = qc.red, 
      foreground = qc.black
   }
   cells.lowStrikeCall.SetColor{
      background = qc.green, 
      foreground = qc.black
   }
   cells.lowStrikePut.SetColor{
      background = qc.red, 
      foreground = qc.black
   }



   SetTableNotificationCallback(self.id, function (t_id, msg, par1, par2)
      local lc    = self.lastClick
      local cells = self.cells
      local qc    = self.QColor

      if msg == QTABLE_LBUTTONDOWN then

         self.lastClick.row = par1
         self.lastClick.col = par2

         -- Выбор опциона
         if lc.row == cells.highStrikeCall.row and        
            lc.col == cells.highStrikeCall.col then

            self.order.ticker    = cells.highStrikeCall.GetValue()
            self.feedOptn.ticker = cells.highStrikeCall.GetValue()   

            cells.selected.SetValue(cells.highStrikeCall.GetValue())
            cells.selected.SetColor{ background = qc.green }
         end

         if lc.row == cells.centrStrikeCall.row and        
            lc.col == cells.centrStrikeCall.col then

            self.order.ticker    = cells.centrStrikeCall.GetValue()
            self.feedOptn.ticker = cells.centrStrikeCall.GetValue() 

            cells.selected.SetValue(cells.centrStrikeCall.GetValue())
            cells.selected.SetColor{ background = qc.green }
         end
         if lc.row == cells.lowStrikeCall.row and        
            lc.col == cells.lowStrikeCall.col then

            self.order.ticker    = cells.lowStrikeCall.GetValue()
            self.feedOptn.ticker = cells.lowStrikeCall.GetValue()

            cells.selected.SetValue(cells.lowStrikeCall.GetValue())
            cells.selected.SetColor{ background = qc.green }
         end
         if lc.row == cells.highStrikePut.row and        
            lc.col == cells.highStrikePut.col then

            self.order.ticker    = cells.highStrikePut.GetValue()
            self.feedOptn.ticker = cells.highStrikePut.GetValue()

            cells.selected.SetValue(cells.highStrikePut.GetValue())
            cells.selected.SetColor{ background = qc.red }
         end
         if lc.row == cells.centrStrikePut.row and        
            lc.col == cells.centrStrikePut.col then

            self.order.ticker    = cells.centrStrikePut.GetValue()
            self.feedOptn.ticker = cells.centrStrikePut.GetValue()

            cells.selected.SetValue(cells.centrStrikePut.GetValue())
            cells.selected.SetColor{ background = qc.red }
         end
         if lc.row == cells.lowStrikePut.row and        
            lc.col == cells.lowStrikePut.col then

            self.order.ticker    = cells.lowStrikePut.GetValue()
            self.feedOptn.ticker = cells.lowStrikePut.GetValue()   

            cells.selected.SetValue(cells.lowStrikePut.GetValue())
            cells.selected.SetColor{ background = qc.red }
         end
         -- знак условия (больше или меньше)
         if lc.row == cells.condSign.row and 
            lc.col == cells.condSign.col then
            
            if cells.condSign.GetValue() == ">" then
               cells.condSign.SetValue("<")
            else
               cells.condSign.SetValue(">")
            end
         end
         -- Тип цены (закрытие свечи или последняя сделка)
         if lc.row == cells.priceType.row and 
            lc.col == cells.priceType.col then

            if cells.priceType.GetValue() == "LAST price" then
               cells.priceType.SetValue("CLOSE price")
            else
               cells.priceType.SetValue("LAST price")
            end
         end
         -- Запуск (или остановка) заявки
         if lc.row == cells.startStop.row and 
            lc.col == cells.startStop.col then

            if cells.startStop.GetValue() == "START" then
               self.doCheckCondition = true
               
               cells.startStop.SetValue("STOP")
               cells.startStop.SetColor {
                  background = qc.red,
                  foreground = qc.black
               }
            else
               self.doCheckCondition = false
               self.order.doFillUp   =false
               cells.startStop.SetValue("START")
               cells.startStop.SetColor {
                  background = qc.green, 
                  foreground = qc.black
               }
            end
         end
         -- Пересчитать страйки ближайших опционов по заданному базовому активу и выводит 3 пута и 3 кола
         --TODO записать дату опциона
         if lc.row == cells.recalc.row and
            lc.col == cells.recalc.col then


            local basePrice = getParamEx(self.baseClass, self.baseTicker, "last").param_value
            local centrStrike = math.floor(basePrice / 2500 + 0.5) * 2500
            

            local optionCall, optionPut = self:GetNearestOptions( centrStrike)
            cells.centrStrikeCall.SetValue(optionCall)
            cells.centrStrikePut.SetValue(optionPut)

            optionCall, optionPut = self:GetNearestOptions(centrStrike + 2500)
            cells.highStrikeCall.SetValue(optionCall)
            cells.highStrikePut.SetValue(optionPut)

            optionCall, optionPut = self:GetNearestOptions(centrStrike - 2500)
            cells.lowStrikeCall.SetValue(optionCall)
            cells.lowStrikePut.SetValue(optionPut)

            cells.expireDate.SetValue( getParamEx(self.optionClass, optionPut, "EXPDATE").param_image)

         end
      end

      if msg == QTABLE_VKEY then
         --message( tostring(par2))
         local isDigit      = par2 >= 48 and par2 <= 57
         local isLetter     = par2 >= 65 and par2 <= 90
         local isBackspace  = par2 == 8 or par2 == 46
         local isLeftArrow  = par2 == 37
         local isRightArrow = par2 == 39
         local isMinus      = par2 == 189
   
       
   
         if lc.row == cells.baseSec.row and 
            lc.col == cells.baseSec.col then

            local text = cells.baseSec.GetValue()
            if isDigit or isLetter then
               
               if string.len(text) < 4 then
                  text = text .. string.char(par2)
                  cells.baseSec.SetValue(text)
                  if string.len(text) == 4 then
                     self.baseTicker = text
                     self.feedBase.ticker = text
                     if self.isLog then message("Тикер изменен ручным вводом") end
                  end
               end
            elseif (isBackspace) then
               if string.len( text ) < 2 then 
                  cells.baseSec.SetValue("")
               else 
                  cells.baseSec.SetValue( text:sub( 1, #text-1) ) 
               end
            end
   
            if isLeftArrow or isRightArrow then
               local letters = cells.baseSec.GetValue():sub(1, 3)
               local digit   = cells.baseSec.GetValue():sub(4, 4)
   
               if letters == "RIH" then
                  if isRightArrow then
                     letters = "RIM"
                  else
                     letters = "RIZ"
                     digit = tonumber(digit) - 1
                     if digit < 0 then
                        digit = 9
                     end
                  end
               elseif letters == "RIM" then
                  letters = isRightArrow and "RIU" or "RIH"
               elseif letters == "RIU" then
                  letters = isRightArrow and "RIZ" or "RIM"
               elseif letters == "RIZ" then
                  if isLeftArrow then
                     letters = "RIU"
                  else
                     letters = "RIH"
                     digit = tonumber(digit) + 1
                     if digit > 9 then
                        digit = 0
                     end
                  end
               end
               self.baseTicker = letters .. tostring(digit)
               self.feedBase.ticker = self.baseTicker
               cells.baseSec.SetValue(self.baseTicker)
            end
         end
   
         if lc.row == cells.basePrice.row and 
            lc.col == cells.basePrice.col then
               
            local strVal = tostring( cells.basePrice.GetValue() )
            local nDigits = string.len(strVal)
   
            if isDigit and nDigits < 6 then
               cells.basePrice.SetValue( tonumber( strVal .. string.char(par2) ) )
            elseif isBackspace then
               if nDigits > 1 then
                  strVal = strVal:sub(1, nDigits - 1)
                  cells.basePrice.SetValue( tonumber(strVal) )
               else
                  cells.basePrice.SetValue("")
               end
            end
   
            if isRightArrow or isLeftArrow then
               cells.basePrice.SetValue(isRightArrow and cells.basePrice.GetValue() + 10 or cells.basePrice.GetValue() - 10)
            end
         end

         if lc.row == cells.quantity.row and 
            lc.col == cells.quantity.col then

            if isDigit then
               local strVal = tostring( cells.quantity.GetValue() ) 
               cells.quantity.SetValue( tonumber( strVal..string.char(par2) ) )
            elseif isBackspace then
               cells.quantity.SetValue(0)
            end
            
            if isMinus then 
               cells.quantity.SetValue(cells.quantity.GetValue()*(-1)) 
            end

            if isRightArrow or isLeftArrow then
               cells.quantity.SetValue( isRightArrow and cells.quantity.GetValue() + 1 or cells.quantity.GetValue() - 1)
            end
            self.order.planned = cells.quantity.GetValue()
            assert(self.order.planned == cells.quantity.GetValue(), "order.plan noteq table.quantity")
         end
      end

   end)
end

function OptionBuyTable:Refresh()
   self.cells.basePriceMonitor.SetValue(self.feedBase.last)
   if self.feedOptn.ticker ~= nil or self.feedOptn.ticker ~= "" then
      self.cells.theorPrice.SetValue(self.feedOptn.theorprice)
      if self.order.isActive then self.order.price = self.feedOptn.theorprice end
   end
   if self.doCheckCondition and self.cells.condSign.GetValue() == ">" then 
      if self.cells.basePriceMonitor.GetValue() > self.cells.basePrice.GetValue() then
         self.order.doFillUp = true
      end
   elseif self.doCheckCondition and self.cells.condSign.GetValue() == "<" then
      if self.cells.basePriceMonitor.GetValue() < self.cells.basePrice.GetValue() then
         self.order.doFillUp = true
      end
   end
   self.order:Process()
end

function OptionBuyTable:SaveTickers( )
   local f = assert(io.open("obt.sav", "w"))
   f:write(self.baseTicker, "\n")
   f:write(self.optionClass, "\n")
   f:write(self.cells.highStrikeCall.GetValue(),  "\n")
   f:write(self.cells.centrStrikeCall.GetValue(), "\n")
   f:write(self.cells.lowStrikeCall.GetValue(),   "\n")
   f:write(self.cells.highStrikePut.GetValue(),   "\n")
   f:write(self.cells.centrStrikePut.GetValue(),  "\n")
   f:write(self.cells.lowStrikePut.GetValue(),    "\n")
   f:write(self.cells.expireDate.GetValue(),      "\n")
   f:close()
end

function OptionBuyTable:LoadTickers( )
   local f = io.open("obt.sav", "r")-- = assert( io.open("obt.sav", "r") )
   if f == nil then return f end
   self.baseTicker  = f:read()
   self.optionClass = f:read()
   self.cells.highStrikeCall.SetValue(  f:read() )
   self.cells.centrStrikeCall.SetValue( f:read() )
   self.cells.lowStrikeCall.SetValue(   f:read() )
   self.cells.highStrikePut.SetValue(   f:read() )
   self.cells.centrStrikePut.SetValue(  f:read() )
   self.cells.lowStrikePut.SetValue(    f:read() )
   self.cells.expireDate.SetValue(      f:read() )
   f:close()
   self.order.market = self.optionClass
end

function OptionBuyTable:GetNearestOptions(strike)
   -- optionsCsvString, strike
   --def
   assert(type(strike) == "string" or 
          type(strike) == "number", 
   "func GetNearestOpt has wrong argument type")

   if type(strike) == "number" then 
      strike = tostring(strike)
   end
   --end def
   --local optionsCsv = getClassSecurities(self.optionClass)
   local optionCall, optionPut
   local optWeekCode = ""
   local countThursday = 0
   local count = 0
   local curTime = os.time()
   for i=1,os.date("*t", curTime).day do
      curTime = curTime - 24*60*60
      if os.date("*t", curTime).wday == 5 then 
         countThursday = countThursday + 1 
      end
   end
   --message(tostring(countThursday))
   if     countThursday == 0 then 
      optWeekCode ="A"
      self.optionClass = "OPTW"
   elseif countThursday == 1 then 
      optWeekCode ="B"
      self.optionClass = "OPTW"
   elseif countThursday == 2 then 
      self.optionClass = "SPBOPT"
   elseif countThursday == 3 then 
      optWeekCode ="D"
      self.optionClass = "OPTW"
   elseif countThursday == 4 then 
      optWeekCode ="E" 
      self.optionClass = "OPTW"
   end

   self.order.market = self.optionClass
   self.feedOptn.classCode = self.optionClass
   local optionsCsv = getClassSecurities( self.optionClass ) 
   -- Взять из недельных опционов ММВБ или месячных Фортс
   for word in string.gmatch( optionsCsv, '([^,]+)' ) do
      if string.find(word, strike, 1, true) ~= nil then
         
         if word:sub(-1) == optWeekCode or optWeekCode == ""  then 
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
   return optionCall, optionPut--, countThursday
end
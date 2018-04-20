dofile(getScriptPath().."\\QOptBaseOrderSpamer\\QTableClass.lua")
dofile(getScriptPath().."\\QOptBaseOrderSpamer\\QTrade.lua")
--
CLIENT = "SPBFUT00154"--SPBFUT00T48
OptionBuyTable = QTableClass:new{
   baseClass = "SPBFUT",
   baseTicker = "RIM8",
   optionClass = nil,--SPBOPT"
   account = nil,
   activOrder = nil,
   doWaitingCond = false
}

function OptionBuyTable:Init()
   --message(tostring(self.baseTicker))
   self:CreateWindow{
      rows = 9, columns = 5, 
      title = "Биржа "..getParamEx( self.baseClass, self.baseTicker, "TRADINGSTATUS" ).param_image, 
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
   self:AddCell{name = "titleRisk",       row = 6, column = 3}

   self:AddCell{name = "basePriceMonitor",row = 7, column = 1}
   self:AddCell{name = "quantity",        row = 7, column = 2}
   self:AddCell{name = "riskMon",         row = 7, column = 3}
   self:AddCell{name = "exInBidOffer",    row = 7, column = 4}

   self:AddCell{name = "condSign",        row = 8, column = 1}

   self:AddCell{name = "basePrice",       row = 9, column = 1}
   self:AddCell{name = "startStop",       row = 9, column = 2}

   self:AddCell{name = "highStrike",      row = 3, column = 1}
   self:AddCell{name = "centrStrike",     row = 4, column = 1}
   self:AddCell{name = "lowStrike",       row = 5, column = 1}

   local cells = self.cells
   local qc    = self.QColor

   --self:LoadTickers()

   self.feedOptn = {
      classCode = self.optionClass,
      ticker    = ""
   }
   setmetatable(self.feedOptn, MarketData)

   cells.basePrice.SetValue( 
      tonumber(
         getParamEx( self.baseClass, self.baseTicker, "last" ).param_value
      )
   )

   cells.baseSec.SetValue(self.baseTicker)
   cells.condSign.SetValue(">")
   cells.exInBidOffer.SetValue("exclude BidOffer")
   cells.startStop.SetValue("START")
   cells.selected.SetValue("")
   cells.titleQnty.SetValue("quantity:")
   cells.quantity.SetValue(0)
   cells.titleBPMon.SetValue("curPrice:")
   cells.titleRisk.SetValue("risk:")
   cells.riskMon.SetValue(0)
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

   self:FillOptionDesk()

   SetTableNotificationCallback(self.id, function (t_id, msg, par1, par2)
      local lc = self.lastClick
      local cells = self.cells
      local qc    = self.QColor

      if msg == QTABLE_LBUTTONDOWN then

         lc.row = par1; lc.col = par2
         --PrintDbgStr("click for row= "..lc.row.." col= "..lc.col)
         -- Выбор опциона
         if lc.row == cells.highStrikeCall.row and        
            lc.col == cells.highStrikeCall.col then

            self.feedOptn.ticker = cells.highStrikeCall.GetValue()   

            cells.highStrikeCall.SetColor{background = qc.yellow}
            cells.selected.SetValue(cells.highStrikeCall.GetValue())
            cells.selected.SetColor{ background = qc.green }
            -- todo желтизна при выборе любой ячейки опц стола
            self:RefreshOptTheorPriceInfo()
            if lc.cell ~= nil and lc.cell ~= cells.highStrikeCall then 
               lc.cell.SetColor{background = lc.color}
            end
            lc.cell = cells.highStrikeCall
            lc.color = qc.green
         end

         if lc.row == cells.centrStrikeCall.row and        
            lc.col == cells.centrStrikeCall.col then

            self.feedOptn.ticker = cells.centrStrikeCall.GetValue() 
            cells.centrStrikeCall.SetColor{background = qc.yellow}
            cells.selected.SetValue(cells.centrStrikeCall.GetValue())
            cells.selected.SetColor{ background = qc.green }
            self:RefreshOptTheorPriceInfo()
            if lc.cell ~= nil and lc.cell ~= cells.centrStrikeCall then 
               lc.cell.SetColor{background = lc.color}
            end
            lc.cell = cells.centrStrikeCall
            lc.color = qc.green
         end
         if lc.row == cells.lowStrikeCall.row and        
            lc.col == cells.lowStrikeCall.col then

            cells.lowStrikeCall.SetColor{background = qc.yellow}
            self.feedOptn.ticker = cells.lowStrikeCall.GetValue()

            cells.selected.SetValue(cells.lowStrikeCall.GetValue())
            cells.selected.SetColor{ background = qc.green }
            self:RefreshOptTheorPriceInfo()
            if lc.cell ~= nil and lc.cell ~= cells.lowStrikeCall then 
               lc.cell.SetColor{background = lc.color}
            end
            lc.cell = cells.lowStrikeCall
            lc.color = qc.green
         end
         if lc.row == cells.highStrikePut.row and        
            lc.col == cells.highStrikePut.col then

            self.feedOptn.ticker = cells.highStrikePut.GetValue()
            cells.highStrikePut.SetColor{background = qc.yellow}
            cells.selected.SetValue(cells.highStrikePut.GetValue())
            cells.selected.SetColor{ background = qc.red }
            self:RefreshOptTheorPriceInfo()
            if lc.cell ~= nil and lc.cell ~= cells.highStrikePut then 
               lc.cell.SetColor{background = lc.color}
            end
            lc.cell = cells.highStrikePut
            lc.color = qc.red
         end
         if lc.row == cells.centrStrikePut.row and        
            lc.col == cells.centrStrikePut.col then

            self.feedOptn.ticker = cells.centrStrikePut.GetValue()
            cells.centrStrikePut.SetColor{background = qc.yellow}
            cells.selected.SetValue(cells.centrStrikePut.GetValue())
            cells.selected.SetColor{ background = qc.red }
            self:RefreshOptTheorPriceInfo()
            if lc.cell ~= nil and lc.cell ~= cells.centrStrikePut then 
               lc.cell.SetColor{background = lc.color}
            end
            lc.cell = cells.centrStrikePut
            lc.color = qc.red
         end
         if lc.row == cells.lowStrikePut.row and        
            lc.col == cells.lowStrikePut.col then

            self.feedOptn.ticker = cells.lowStrikePut.GetValue()   
            cells.lowStrikePut.SetColor{background = qc.yellow}
            cells.selected.SetValue(cells.lowStrikePut.GetValue())
            cells.selected.SetColor{ background = qc.red }
            self:RefreshOptTheorPriceInfo()
            if lc.cell ~= nil and lc.cell ~= cells.lowStrikePut then 
               lc.cell.SetColor{background = lc.color}
            end
            lc.cell = cells.lowStrikePut
            lc.color = qc.red
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
         if lc.row == cells.exInBidOffer.row and 
            lc.col == cells.exInBidOffer.col then

            if cells.exInBidOffer.GetValue() == "exclude BidOffer" then
               cells.exInBidOffer.SetValue("include limitBidOffer")
            elseif  cells.exInBidOffer.GetValue() == "include limitBidOffer" then
               cells.exInBidOffer.SetValue("include BidOffer")
            else
               cells.exInBidOffer.SetValue("exclude BidOffer")
            end
         end
         -- Запуск (или остановка) заявки
         if lc.row == cells.startStop.row and 
            lc.col == cells.startStop.col then

            if cells.startStop.GetValue() == "START" then
               self.doWaitingCond = true 
               cells.startStop.SetValue("STOP")
               cells.startStop.SetColor {
                  background = qc.red,
                  foreground = qc.black
               }
               --self:SendOrder()
            else
               --self.doWaitingCond = false
               self:ResetStartBtn()
               self:CancelActivOrder()
            end
         end
         -- Пересчитать страйки ближайших опционов по заданному базовому активу и выводит 3 пута и 3 кола
         --TODO записать дату опциона
         if lc.row == cells.recalc.row and
            lc.col == cells.recalc.col then

            self:FillOptionDesk()
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
   
         if lc.row == cells.selected.row and
            lc.col == cells.selected.col then

            local text = cells.selected.GetValue()
            if isDigit or isLetter then 
               text = text..string.char(par2) 
               cells.selected.SetValue(text)
            elseif isBackspace then
               if text:len() < 2 then cells.selected.SetValue("")
               else cells.selected.SetValue( text:sub(1, #text-1) ) end
            end
         end
   
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
            
            self:ShowRisk()
         end
      end

      if msg == QTABLE_CLOSE then
         if self.activOrder ~= nil then self:CancelActivOrder() end
         isRun, isScriptRun = false, false 
      end

   end)
end

function OptionBuyTable:ResetStartBtn(  )
   self.doWaitingCond = false
   self.cells.startStop.SetValue("START")
   self.cells.startStop.SetColor {
      background = self.QColor.green, 
      foreground = self.QColor.black
   }
end

function OptionBuyTable:CancelAllOrders(  )
   assert(self.account, "Не задан счет для ордера")
   assert(self.optionClass, "Не определена биржа опциона для ордера")

   local result = sendTransaction({
      ACCOUNT=self.account,
      --CLIENT_CODE=self.client,
      CLASSCODE=self.optionClass,
      BASE_CONTRACT=self.cells.selected.GetValue(),
      TRANS_ID=_transId,
      ACTION="KILL_ALL_FUTURES_ORDERS",
    })
    assert(result == "", "Ошибка отмены всех заявок"..result)
    self:SetWindowTitle("cansel order for "..self.cells.selected.GetValue())
end
--
function OptionBuyTable:CancelActivOrder( )
   if self.activOrder ~= nil and self.activOrder.order_num ~= nil then

      local result = sendTransaction{
         ACCOUNT     = self.activOrder.account,
         --CLIENT_CODE = self.client,
         CLASSCODE   = self.activOrder.class_code,--optionClass,
         SECCODE     = self.activOrder.sec_code,--cells.selected.GetValue(),
         TRANS_ID    = "666",
         ACTION      = "KILL_ORDER",
         ORDER_KEY   = tostring(self.activOrder.order_num)
      }
      if assert(result == "", "ERR cancel order: "..result) then 
         PrintDbgStr("result =  активный ордер снят") 
         local account = self.activOrder.account
         local class_code = self.activOrder.class_code
         local sec_code = self.activOrder.sec_code
         local operation = self.activOrder.operation
         local balance = self.activOrder.balance
         self.activOrder = nil
         return result,
         {
            ["account"]=account, 
            ["class_code"]=class_code, 
            ["sec_code"]=sec_code, 
            ["operation"]=operation, 
            ["balance"]=balance
         }
      end
      return result, {}
   end
end

function OptionBuyTable:SendOrder(  )
   local tp = assert(self.feedOptn.theorprice, "Не могу взять теор цену для заявки на покупку опциона")

   local qty = self.cells.quantity.GetValue()

   local result = sendTransaction{
      ACCOUNT     = self.account,
      --CLIENT_CODE = self.client,
      CLASSCODE   = self.optionClass,
      SECCODE     = self.cells.selected.GetValue(),
      TYPE        = "L",
      TRANS_ID    = tostring(_transId),
      ACTION      = "NEW_ORDER",
      OPERATION   = qty > 0 and "B" or "S",
      PRICE       = tostring(tp),
      QUANTITY    = tostring( math.abs( qty ) )
   }
   assert(result=="","Err TransSend: "..result)
   PrintDbgStr("Trans send "..self.cells.selected.GetValue()..result )
   
end

function IsActivOrderInSpread(  )
   -- body
   if self.activOrder == nil then return false end
   local bestBid    = self.feedOptn.bid
   local bestBidQty = self.feedOptn.biddepth
   local bestOffer    = self.feedOptn.offer
   local bestOfferQty = self.feedOptn.offerdepth
   local aoPrice   = self.activOrder.price
   local aoBalance = self.activOrder.balance
   return (bestBid == aoPrice and bestBidQty == aoBalance) or
          (bestOffer == aoPrice and bestOfferQty == aoBalance)
end

function OptionBuyTable:MoveActivOrder( )
   if self.activOrder == nil then return end 
    
   local lastOrder = self.activOrder 
   local tp = self.feedOptn.theorprice
   local exCond = self.cells.exInBidOffer.GetValue()
   local neededPrice

   if exCond:find("include") then
      -- учитывание цен стакана( если в стакане превзойдена теор цена)
      local isActivOrderForLong = lastOrder.operation == "B"
      --local selectBest = isActivOrderForLong and math.max or math.min
      -- проверка что лучш цена в стакане не своя заявка, иначе отмена заявки и пересчет цены выставленияs
      if self:IsActivOrderInSpread() then 
         local error
         error, lastOrder = self:CancelActivOrder()
         if error ~= "" then PrintDbgStr(error);return end
         neededPrice = isActivOrderForLong and self.feedOptn.bid or self.feedOptn.offer
      end
      --сравним с лучшей ценой в стакане
      --neededPrice = selectBest( tp, stakanBestOffer)
      --не дальше 4 шагов от теор цены
      if exCond:find("limit") and math.abs(tp - neededPrice) >= 40 then 
         if isActivOrderForLong then neededPrice = tp + 40
         else neededPrice = tp - 40 end
      end
   else --простое следование за теор ценой
      neededPrice = tp
   end


   if self.activOrder ~= nil and self.activOrder.price == neededPrice then return end
   --PrintDbgStr("active order price = "..self.activOrder.price.." theorpr= "..self.feedOptn.theorprice)
   local newOrder = {
      ACCOUNT     = lastOrder.account,
      CLASSCODE   = lastOrder.class_code,
      SECCODE     = lactOrder.sec_code,
      TYPE        = "L",
      TRANS_ID    = tostring(_transId),
      ACTION      = "NEW_ORDER",
      OPERATION   = lastOrder.operation,
      PRICE       = tostring(neededPrice),
      QUANTITY    = tostring( lastOrder.balance )
   }
   
   if self.activOrder ~= nil then
      PrintDbgStr("Отмена акт орд для перестановки")
      self:CancelActivOrder() 
   end
   PrintDbgStr("Перестановка")
   local result = sendTransaction(newOrder)
   assert(result == "", "Ошибка перестановки активного ордера"..result)
end

function OptionBuyTable:RefreshBaseTickerInfo()
   self.cells.basePriceMonitor.SetValue( 
      tonumber(
         getParamEx( self.baseClass, self.baseTicker, "last" ).param_value
      )
   )
end

function OptionBuyTable:RefreshOptTheorPriceInfo( )
   if self.feedOptn.ticker ~= nil or self.feedOptn.ticker ~= "" then
      self.cells.theorPrice.SetValue(self.feedOptn.theorprice)
   end
end

function OptionBuyTable:ShowRisk(  )
   local qty = self.cells.quantity.GetValue()
   if qty == 0 then return end
   local price = self.cells.theorPrice.GetValue()
   if type(price) == 'string' then return end
   local curStepPriceCost = self.feedOptn.stepprice
   local priceStep = self.feedOptn.sec_price_step
   
   local risk = curStepPriceCost * price / priceStep * qty
   --PrintDbgStr(curStepPriceCost.." * "..priceStep.." / "..price.." * "..qty.." = "..risk)
   self.cells.riskMon.SetValue( math.ceil( math.abs(risk) ).." руб" )
end

function OptionBuyTable:CheckConditionForPoseGain(  )
   PrintDbgStr("проверяем цену ба на условие")
   if  self:IsConditionMet() ~= true then
      
      PrintDbgStr("усл ФАЛЬШ")
      return 
   end
   PrintDbgStr("усл-е выполнено, ПОсылаем ордер")
   self.doWaitingCond = false
   self:SendOrder()
end

function OptionBuyTable:IsConditionMet(  )
   if self.cells.condSign.GetValue() == ">" then
      return tonumber(self.cells.basePriceMonitor.GetValue() ) > tonumber(self.cells.basePrice.GetValue() )
   elseif self.cells.condSign.GetValue() == "<" then
      return tonumber(self.cells.basePriceMonitor.GetValue() ) < tonumber(self.cells.basePrice.GetValue() )
   end
   return nil
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
end

function OptionBuyTable:GetOptions( )
   return getClassSecurities(self.optionClass)
end

function OptionBuyTable:GetRiOptsByStrike(neededStrike)
   assert(type(neededStrike) == "string" or 
          type(neededStrike) == "number", 
   "func GetNearestOpt has wrong argument type")

   if type(neededStrike) == "number" then 
      neededStrike = tostring(neededStrike)
   end
   PrintDbgStr("needed strike is "..neededStrike)
   --end def

   local optnsStr = self:GetOptions()
   local optnPattern = "(%a%a)([%d%.]+)%a(%a)(%d)"--(%a)"
   local options = {}
   for word in string.gmatch( optnsStr,'[^,]+' ) do
   --   PrintDbgStr(word) 
      local base, strike, type, year, week = string.match( word,optnPattern )
      --local class = week ~= nil and "OPTW" or "SPBOPT"
      if base == "RI" and strike == neededStrike then
         
         local option = {
            strike = tonumber(neededStrike),
            expireDate = getParamEx(self.optionClass, word, "expdate").param_image ,
            type   = getParamEx(self.optionClass, word, "optiontype").param_image,
            name   = word,
            daysToExpire = tonumber(
               getParamEx(self.optionClass, word, "DAYS_TO_MAT_DATE").param_value
            ),
            weekCode = week
         }
         -- PrintDbgStr(option.name.." de= "..option.daysToExpire.." week ="..tostring(option.weekCode))
         if option.daysToExpire > -1 then table.insert( options, option ) end
      end
   end
   -- поиск опцов с ближайшим истечением
   local indexNearestOpt=1
   local minDaysToExp = options[indexNearestOpt].daysToExpire
   for i,opt in ipairs(options) do
      if opt.daysToExpire < minDaysToExp then 
         minDaysToExp = opt.daysToExpire
         indexNearestOpt = i
      end
   end
   -- неизвестен порядок Пута и Кола, вернуть обязательно первым значением Колл
   if options[indexNearestOpt].type == "Put" then
      return options[indexNearestOpt + 1], options[indexNearestOpt]
   end
   return options[indexNearestOpt], options[indexNearestOpt+1]
end

function OptionBuyTable:FillOptionDesk(  )

   local basePrice = getParamEx(self.baseClass, self.baseTicker, "last").param_value
   local centrStrike = math.floor(basePrice / 2500 + 0.5) * 2500

   assert(tonumber(centrStrike)>0, "Cant get base price to fill option desk")

   local optionCall, optionPut = self:GetRiOptsByStrike( centrStrike)
   self.cells.centrStrikeCall.SetValue(optionCall.name)
   self.cells.centrStrikePut.SetValue(optionPut.name)

   optionCall, optionPut = self:GetRiOptsByStrike(centrStrike + 2500)
   self.cells.highStrikeCall.SetValue(optionCall.name)
   self.cells.highStrikePut.SetValue(optionPut.name)

   optionCall, optionPut = self:GetRiOptsByStrike(centrStrike - 2500)
   self.cells.lowStrikeCall.SetValue(optionCall.name)
   self.cells.lowStrikePut.SetValue(optionPut.name)

   self.cells.expireDate.SetValue( optionCall.expireDate )--getParamEx(self.optionClass, optionPut.name, "EXPDATE").param_image)
end
MarketData = {
   __index = function ( oTable, key )
      local params = getParamEx(oTable.classCode, oTable.ticker, key)
      --message("in Market Data")
      if params.result == "0" then  return "Параметр данного Тикера не найден" end
      if tonumber(params.param_type) < 3 then
         return tonumber(params.param_value)
      else 
         return params.param_image 
      end
   end
}

ActivOrder = {}
function ActivOrder:New( obj )
   obj = obj or {}
   self.__index = self
   setmetatable(obj, self)
   
   return obj
end
function ActivOrder:Reset(  )
   self.id = nil
   self.price = nil
   self.qty = nil
   self.dir = nil
end

QSmartOrder = {}

function QSmartOrder:new( obj )
   obj = obj or {}
   setmetatable(obj, self)
   self.__index = self

   obj.trans_id = tostring(os.time())

   return obj
end

function QSmartOrder:Process(  )
   
   if not self.doFillUp then return end
   --message('SmartOrder is Active')
   if self.standingOrder == nil then 
      if self:Remainder() ~= 0 then self:SendNewOrder() end

   else
      if not self.standingOrder.isActive then 
         local filled = self.standingOrder.filled * self.standingOrder.sign
         self.position = self.position + filled
         self.standingOrder = nil
      else
         if self.standingOrder.price ~= self.price or self:Remainder() - self.standingOrder.quantity ~= 0 then
            if self:KillOrder() then 
               self.standingOrder = nil
            end
         end

      end
   end





end

function QSmartOrder:Turn ()
   if self.doFillUp then 
      self.doFillUp = false
      message("isActive false")
   else 
      self.doFillUp = true
      message("isActive true")
   end
end

function QSmartOrder:SendNewOrder( ... )
   --message(self.account..self.client..self.market..self.ticker)
   local result = sendTransaction{
      ACCOUNT     = self.account,
      CLIENT_CODE = self.client,
      CLASSCODE   = self.market,
      SECCODE     = self.ticker,
      TYPE        = "L",
      TRANS_ID    = tostring(self.trans_id),
      ACTION      = "NEW_ORDER",
      OPERATION   = self:Remainder() > 0 and "B" or "S",
      PRICE       = tostring(self.price),
      QUANTITY    = tostring( math.abs( self:Remainder() ) )
   }
   if result == "" then
      self.standingOrder = {
         sign = self:Remainder() / math.abs( self:Remainder() ),
         price = self.price,
         quantity = self:Remainder(),
         isActive = true,
         filled   = 0
      }
      message("Транзакция принята standingOrder="..tostring(self.standingOrder).."price= "..self.standingOrder.price)
   else 
      message('Error newOrder: '..result)
   end
   
end

function QSmartOrder:KillOrder( ... )
   local result = sendTransaction{
      ACCOUNT     = self.account,
      CLIENT_CODE = self.client,
      CLASSCODE   = self.market,
      SECCODE     = self.ticker,
      TRANS_ID    = "666",
      ACTION      = "KILL_ORDER",
      ORDER_KEY   = tostring(self.standingOrder.number)
   }
   if result == "" then
      self.standingOrder.cancelled = os.time()
      return true
   else
      message('Error killOrder :'..result)
      return false
   end
end

function QSmartOrder:isFilled()
   return self:Remainder() == 0
end

function QSmartOrder:Remainder()
   
   return self.planned - self.position
end

function QSmartOrder:Update( price, planned )
   self.price   = assert(price, "wrong orderPrice update")
   self.planned = assert(planned, "wrong orderQuantaty update")
end
dofile(getScriptPath().."\\QOptBaseOrderSpamer\\QView2.lua")

_optMarket = getInfoParam("IPCOMMENT") == "QUIK-JUNIOR" and "SPBOPT" or "OPTW"
_account   = _optMarket == "SPBOPT" and "SPBFUT000hp" or "needToEstablish"
_baseTicker = "RIM8" 
_transId = 1979

isRun = true

function OnInit(  )

   obt = OptionBuyTable:new()
   obt.optionClass = _optMarket
   obt.baseTicker  = _baseTicker
   obt.account = _account

   obt:Init()
   --obt:LoadTickers()

end

function main(  )

	while isRun do
      --order = obt:Refresh()
      --if order ~= nil then message("Uray!!! "..order) end

		sleep(2000)
	end
end

function OnStop()
   --obt:SaveTickers ()
	obt:Delete()
   isRun = false;
   return 3000
end

function OnClose()

end

function OnTransReply(info)
   if info.trans_id == _transId and 
      info.status   == 3
      then
      
      info.operation = bit.band(info.flags, 20000) > 0 and "S" or "B"
      PrintDbgStr("Trans Reply 1979 получен, передаю номер ордера, ")
      PrintDbgStr("направ сделки "..info.operation)
      obt.activOrder = info

   end
end

function OnOrder( order )
   if order.trans_id == _transId then
      local isActive = bit.band(order.flags, 1) > 0
      if isActive then
         order.operation = bit.band(order.flags, 4) > 0 and "S" or "B"
         PrintDbgStr("ОнОрдер направ "..order.operation)
         obt.activOrder = order
      else
         obt.activOrder = nil
         PrintDbgStr("Заявка закрыта")
      end
   end
   PrintDbgStr(order.order_num..' flag= '..order.flags)
end

function OnQuote( market, ticker)
   -- колбэк для Стакана
end

function OnParam( market, ticker )
      if market == obt.baseClass and ticker == obt.baseTicker then
         obt:RefreshBaseTickerInfo()
      end

      if market == obt.optionClass and ticker == obt.cells.selected.GetValue() then
         obt:RefreshOptTheorPriceInfo()
         if obt.activOrder == nil then return end
         obt:MoveActivOrder() 
      end
end


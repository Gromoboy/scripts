dofile(getScriptPath().."\\QOptBaseOrderSpamer\\QView2.lua")
dofile(getScriptPath().."\\QOptBaseOrderSpamer\\QCore.lua")



_optMarket = (getInfoParam("IPCOMMENT") == "QUIK-JUNIOR" or IsMonthOptionWeekNow()) and
 "SPBOPT" or 
 "OPTW"
_account   = getInfoParam("IPCOMMENT") == "QUIK-JUNIOR" and "SPBFUT000hp" or "SPBFUT00T48"
_baseTicker = "RIM8" 
_transId = 1979

isRun = true

function OnInit(  )


   --obt:LoadTickers()

end

function main(  )

   obt = OptionBuyTable:new()
   obt.optionClass = _optMarket
   obt.baseTicker  = _baseTicker
   obt.account = _account

   obt:Init()
   local unique_id = tostring( {} ):sub(8)
	while isRun do
      --order = obt:Refresh()
      --if order ~= nil then message("Uray!!! "..order) end
      --PrintDbgStr("для просмотра в дебаге номера процесса"..unique_id)
		sleep(2000)
	end
end

function OnStop()
   --obt:SaveTickers ()
   if obt.activOrder ~= nil then obt:CancelActivOrder() end
	obt:Delete()
   isRun = false;
   return 3000
end

function OnClose()

end

function OnTransReply(info)
   if info.trans_id ~= _transId then return end 
   if info.status   == 3 then
      
      info.operation = bit.band(info.flags, 20000) > 0 and "S" or "B"
      PrintDbgStr("Trans Reply 1979 получен, передаю номер ордера, ")
      PrintDbgStr(info.order_num.." направ сделки "..info.operation)
      obt.activOrder = info
   else
      message(info.result_msg, 3)
   end
end

function OnOrder( order )
   if order.trans_id == _transId then
      local isActive = bit.band(order.flags, 1) > 0
      if isActive then
         order.operation = bit.band(order.flags, 4) > 0 and "S" or "B"
         PrintDbgStr("ОнОрдер направ "..order.operation.." qty= "..order.qty)
         obt.activOrder = order
      else
         obt.activOrder = nil
         obt:ResetStartBtn()
         PrintDbgStr("Заявка закрыта")
      end
    PrintDbgStr(order.order_num..' flag= '..order.flags)   
   end
  
end

function OnQuote( market, ticker)
   -- колбэк для Стакана
   if obt.activOrder ~= nil and 
      ticker         == obt.activOrder.sec_code and 
      obt.cells.exInBidOffer.GetValue():find("include") then
         obt:MoveActivOrder()
      end
end

function OnParam( market, ticker )
   if market == obt.baseClass and ticker == obt.baseTicker then
      obt:RefreshBaseTickerInfo()
      --local unique_id = tostring( {} ):sub(8)
      --PrintDbg("callback process id = "..unique_id)
      if obt.doWaitingCond then obt:CheckConditionForPoseGain() end
   end

   if market == obt.optionClass and obt.cells.selected ~= nil and ticker == obt.cells.selected.GetValue() then
      obt:RefreshOptTheorPriceInfo()
      obt:ShowRisk()
      if obt.activOrder == nil then return end
      obt:MoveActivOrder() 
   end
end


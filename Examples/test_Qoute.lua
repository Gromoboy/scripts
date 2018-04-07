dofile(getScriptPath().."\\QOptBaseOrderSpamer\\QViews.lua")


isScriptRunning = true

_class = "SPBFUT" --getInfoParam("IPCOMMENT") == "QUIK-JUNIOR" and "SPBOPT" or "OPTW"
_ticker = "RIM8" 


function OnInit(  )

end


function main(  )
   if( not IsSubscribed_Level_II_Quotes(_class, _ticker)) then
      Subscribe_Level_II_Quotes(_class, _ticker)
   end
   sleep(2000)

   PrintDbgStr("Стакан подписан? = "..tostring(IsSubscribed_Level_II_Quotes(_class, _ticker)))
   local stakan = getQuoteLevel2(_class, _ticker)
   for i = 1, stakan.bid_count do
      PrintDbgStr(tostring(stakan.bid[i].price).."; "..tostring(stakan.bid[i].quantity).."\n")
   end

	while isScriptRunning do
      
      
		sleep(2000)
	end
end


function OnStop()

	isScriptRunning = false;
end

function OnQuote( code, sec )
   -- if code == _class and sec == _ticker then
   --    message( code.." "..sec, 1)
   -- end
 
end


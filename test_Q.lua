dofile(getScriptPath().."\\QOptBaseOrderSpamer\\QViews.lua")


isScriptRunning = true

_class = getInfoParam("IPCOMMENT") == "QUIK-JUNIOR" and "SPBOPT" or "OPTW"
_ticker = "RIM8" 


function OnInit(  )

end


function main(  )

   --assert(false, "Ooops!")
   local optStr = getClassSecurities(_class)
   local timeNow = getInfoParam("TRADEDATE")
   local day, month, year = string.match( timeNow,"(%d%d).(%d%d).(%d%d%d%d)" )
   timeNow = year * 10000 + month*100 + day
   --timeNow = timeNow.year
   PrintDbgStr(tostring(timeNow))
    PrintDbgStr(tostring(optStr))
   local expDate
   for word in string.gmatch( optStr,'[^,]+' ) do
      if word:find("125000") then
         PrintDbgStr(word)
         expDate = getParamEx(_class, word, "expdate").param_value
        -- if expDate > then
        --       
        -- end
         PrintDbgStr(tostring(expDate) )
      end
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


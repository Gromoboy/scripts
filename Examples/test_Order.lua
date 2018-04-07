
isScriptRunning = true

_class = "SPBFUT" --getInfoParam("IPCOMMENT") == "QUIK-JUNIOR" and "SPBOPT" or "OPTW"
_ticker = "RIM8"

_buyOrder ={
   num = "",
   price = 0,
   reminder = 0
}

_sellOrder = {
   num = "",
   price = 0,
   reminder = 0
}


function OnInit(  )

end


function main(  )
  

	while isScriptRunning do
      
      
		sleep(2000)
	end
end


function OnStop()

	isScriptRunning = false;
end

function OnOrder(order)
   PrintDbgStr( order.order_num.." flags= "..order.flags)
end


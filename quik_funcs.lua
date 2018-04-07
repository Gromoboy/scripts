function is_session_active_for_ticker( class, ticker )
	if(getParamEx (class, ticker, "STATUS").result == "0") then
		return nil
	end
	if (tonumber(getParamEx (class, ticker, "STATUS").param_value) == 1) then
		return true
	else
		return false
	end
end
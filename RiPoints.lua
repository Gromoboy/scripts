dofile(getScriptPath().."\\QTable.lua")

isRun = true

function OnInit(  )
	n_kon = 30
	n_pnt = 800
   ticker = 'RIM8'
   tickerCell = {}
	x, y, dx, dy = 1020, 700, 325, 240
	riskPerTrade = 500
end


function main(  )
	qtable = PlaceRtsPntTable(x, y, dx, dy, n_kon, ticker)
	-- Fill n_rows
	-- first column 
	for val=10,n_pnt,10 do
		local row = qtable:AddLine()
		q_table:SetValue(row, "pnt", val, "blue")
	end
	-- other colums
	local cur_step_price = getParamEx('SPBFUT', ticker, 'STEPPRICE').param_value
	cur_step_price = tonumber(cur_step_price)

	for row = 1, n_pnt/10 do
		local points = q_table:GetValue(row, "pnt").image
		points = tonumber(points)

		for col = 1, n_kon do
			local col_name = tostring(col).." k"
			local pntInRuble = math.ceil( cur_step_price * points/10 * col )
			local cell_color = pntInRuble < riskPerTrade and "green" or nil
			q_table:SetValue(row, col_name, pntInRuble, cell_color)

		end
	end
    --last column add and fill
    tickerCell.row = qtable:AddLine()
    tickerCell.col = qtable.columns["pnt"].id
    qtable:SetValue(tickerCell.row, "pnt", ticker)
    
	while isRun do

		sleep(500)
	end
end


function OnStop()
	qtable:Delete()
	isRun = false;
end;

function PlaceRtsPntTable (x, y, dx, dy, n_kon, ticker)
	local qtable = QTable.new()

	qtable:AddColumn("pnt", QTABLE_CACHED_STRING_TYPE, 6)
	for i=1,n_kon do
		qtable:AddColumn(tostring(i).." k", QTABLE_STRING_TYPE, 6)
	end

	qtable:SetCaption(ticker.." пункты в руб*кон")
	qtable:Show()
    qtable:SetPosition(x, y, dx, dy)
    qtable:SetOnEvent(eventHandler)
	return q_table
end

function eventHandler( t_id, msg, par1, par2 )

   if msg == QTABLE_LBUTTONDOWN then
     if par1 == tickerCell.row and par2 == tickerCell.col then 
         SetCell(t_id, par1, par2, "RIZ8")
     end
   end
end
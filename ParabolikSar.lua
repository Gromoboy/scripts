--dofile(getScriptPath().."dll_robot.lua")

is_run = true

function OnInit ( )
	TableId = AllocTable()
	AddColumn(TableId, 1, "���������",true, QTABLE_STRING_TYPE, 20 )
	AddColumn(TableId, 2, "��������", true,QTABLE_STRING_TYPE, 20 )
	AddColumn(TableId, 3, "�����������",true, QTABLE_STRING_TYPE, 20)
	CreateWindow(TableId)

	SetWindowCaption(TableId,"����� ���������")
	SetWindowPos(TableId, 100, 100, 500, 200)
	InsertRow(TableId, -1)
	SetCell(TableId, 1, 1, "��������� �����")

	message("����� �������", 1)
end

function main( )
	while is_run do
		local  Servertime = getInfoParam("SERVERTIME")
		if Servertime == "" then
			message("cant get time from server", 3)
			return
		end
		--local success = SetCell(TableId, 1, 2, Servertime)
		if SetCell(TableId, 1, 2, Servertime) then
			SetCell(TableId, 1, 3, "ok")
		else
			message("didnt set cell",2)
		end
		--message(Servertime, 1)
		sleep(1000)
	end
end

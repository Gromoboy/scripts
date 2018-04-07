dofile(getScriptPath().."\\QOptBaseOrderSpamer\\QViews2.lua")

isRun = true

function OnInit(  )
   
end

function main(  )

    
	while isRun do

		sleep(100)
	end
end

function OnStop()
	--obt:Delete()
	isRun = false;
end;
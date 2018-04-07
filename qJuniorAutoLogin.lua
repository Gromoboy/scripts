-- Аптоввод пароля для демо Квика

local w32 = require("w32")

JUNIOR_LOGIN    = "U0121954"
JUNIOR_PASSWORD = "87654321qQ"

timeout = 1000
isRun = true

function OnStop(  )
   isRun = false
end

function main(  )
   while isRun do
      sleep(timeout)

      if isConnected() == 0 then
         local hLoginWnd = w32.FindWindow("","Идентификация пользователя")
         if hLoginWnd ~= 0 then
            -- перебор детей
            local hServer = w32.FindWindowEx(hLoginWnd, 0, "", "")
            local hLogin = w32.FindWindowEx(hLoginWnd, hServer, "", "")
            local nPassw = w32.FindWindowEx(hLoginWnd, hLogin, "", "")
            local nBtnOk = w32.FindWindowEx(hLoginWnd, nPassw, "", "")

            w32.SetWindowText(hLogin, JUNIOR_LOGIN)
            w32.SetWindowText(nPassw, JUNIOR_PASSWORD)
 
            w32.SetFocus(nBtnOk)
            w32.PostMessage(nBtnOk, w32.BM_CLICK, 0, 0)
 
            while not isConnected() do sleep(10); end;
         end
      end
   end

end
QTable = {}
QTable.__index = QTable

function QTable.new()
   local t_id = AllocTable()
   if t_id == nil then return t_id end

   q_table = {}

   q_table.id = t_id
   q_table.caption = ""
   q_table.is_win_created = false
   q_table.last_col = 0
   q_table.columns = {} -- таблица с параметрами столбцов

   setmetatable(q_table, QTable)
   return q_table
end

function QTable:Show()
   CreateWindow(self.id)
   if self.caption ~= "" then SetWindowCaption(self.id, self.caption) end
   self.is_win_created = true
end

function QTable:IsWinClosed()
   return IsWindowClosed(self.id)
end

function QTable:Delete()
   DestroyTable(self.id)
end

function QTable:GetCaption ()
   return IsWindowClosed(self.id) and self.caption or GetWindowsCaption(self.id)
end

function QTable:SetCaption (str)
   self.caption = str
   if not IsWindowClosed(self.id) then
      SetWindowCaption(self.id, tostring(str))
   end
end

function QTable:AddColumn(name, col_type, width)
   self.last_col = self.last_col+1

   local col_desc = {}
   col_desc.col_type = col_type
   col_desc.id = self.last_col
   self.columns[name] = col_desc

   AddColumn(self.id, self.last_col, name, true, col_type, width)
end

function QTable:Clear ()
   Clear(self.id)
end

function QTable:SetValue (row, col_name, data, background)
   local col_ind = self.columns[col_name].id
   if col_ind == nil then return false end

   if type(data) == "string" then
      SetCell(self.id, row, col_ind, data)
   else
      SetCell(self.id, row, col_ind, tostring(data), data)
   end

   if( background == "blue") then
      SetColor(self.id, row, col_ind, RGB(0, 184, 217), RGB(0,0,0), RGB(255,0,0), RGB(0,0,0))
   elseif background == "green" then
      SetColor(self.id, row, col_ind, RGB(150,255,150), RGB(0,0,0), RGB(150,255,150), RGB(0,0,0))
   end
end

function QTable:AddLine()
   return InsertRow(self.id, -1)
   --возвращает номер добавленного ряда(-1 означат добавить в конец, т.е. последний)
end

function QTable:GetSize ()
   -- return NUMBER rows, NUMBER col
   return GetTableSize(self.id)
end

function QTable:GetValue (row, name)
   local col_ind = self.columns[name].id
   if col_ind == nill then return col_ind end
   --возвращает таблицу с двумя значениями:
   --image строковое представление значения ячейки
   --value числовое значение ячейки
   return GetCell(self.id, row, col_ind)
end

function QTable:SetPosition (x, y, dx, dy)
   return SetWindowPos(self.id, x, y, dx, dy)
end

function QTable:GetPosition ()
   top, left, bottom, right = GetWindowRect(self.id)
   return top, left, bottom, right
end

function QTable:SetOnEvent( funcName )
   if type(funcName) ~= "function" then return 0 end
    --return 1 if all set. elses ret 0
    return SetTableNotificationCallback(self.id, funcName)
end
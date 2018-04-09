QTableClass = {
   QColor = {
      black = RGB(0,0,0), green = RGB(100,250,100), red = RGB(255,0,0), white = RGB(255,255,255), blue = RGB(0,0,255), yellow = RGB(255,255,0)
   }
}


function QTableClass:new( obj )
     
   obj = obj or {}
   setmetatable(obj, self)
   self.__index = self
   
  
   obj.lastClick = {}
   --    row = 1,
   --    col = 1
   -- }
   obj.cells = {}
   obj.id = AllocTable()
 
   return obj
end

function QTableClass:CreateWindow(init)
   -- rows, columns, title, colWidth
   if type(init.colWidth) == "nil" then init.colWidth = 8 end
   for i=1, init.columns do
      AddColumn(self.id, i, tostring(i), true, QTABLE_STRING_TYPE, init.colWidth)
   end
   CreateWindow(self.id)
   for i=1, init.rows do
      InsertRow(self.id, -1)
   end
   if init.title ~= nil and init.title ~= "" then
      -- SetWindowCaption(self.id, tostring(init.title))
      self:SetWindowTitle(init.title)
   end
end

function QTableClass:SetWindowTitle( title )
   return SetWindowCaption(self.id, tostring(title))
end
function QTableClass:GetSize(  )
   -- returns QTableClassNUMBER rows, NUMBER columns
   
   return GetTableSize(self.id)
end

function QTableClass:AddCell( args )
   -- name, row, columns

   local cell = {}
   cell.row = assert(args.row, "не могу добавить €чейку без р€да")
   cell.col = assert(args.column, "не могу добав €чейку без колонки")
  
   cell.SetValue = function( value )
      if type(value) == "string" then
         cell.value = nil
         return SetCell(self.id, args.row, args.column, value)
      elseif type(value) == "number" then
         cell.value = value
         value = tostring( math.floor(value) ):reverse():gsub("%d%d%d","%1 "):reverse():gsub("^ ","")
         return SetCell(self.id, args.row, args.column, value)
      else 
         return "nil"
      end
   end
   cell.SetValue(args.name)
   cell.GetValue = function ()
      if cell.value ~= nil then return cell.value end
      return GetCell(self.id, args.row, args.column).image
   end

   cell.SetColor = function(colors)
      -- background, foreground, selectedBackground, selectedForeground
      colors.background = colors.background or QTABLE_DEFAULT_COLOR
      colors.foreground = colors.foreground or QTABLE_DEFAULT_COLOR
      colors.selectedBackground = colors.selectedBackground or QTABLE_DEFAULT_COLOR
      colors.selectedForeground = colors.selectedForeground or QTABLE_DEFAULT_COLOR
      --message(tostring(args.row)..tostring(args.column))
      return SetColor(self.id, args.row, args.column, colors.background, colors.foreground, colors.selectedBackground, colors.selectedForeground) 
   end
   self.cells[args.name] = cell


end

function QTableClass:SetWinPos(args)
   -- x,y,dx,dy
   if type(args.x) ~= "number" or type(args.y) ~= "number" or type(args.dx) ~= "number" or type(args.dy) ~= "number" then
      local top, left, bottom, right = GetWindowRect(self.id)
      args.x = args.x or left
      args.y = args.y or top
      args.dx = args.dx or right
      args.dy = args.dy or bottom
   end
   return SetWindowPos(self.id, args.x, args.y, args.dx, args.dy)
end

function QTableClass:Delete(  )
   --message(tostring(self.id),1)
   DestroyTable(self.id)
end

function QTableClass:SetOnEvent( funcName )
   if type(funcName) ~= "function" then return 0 end
    --return 1 if all set. elses ret 0
    return SetTableNotificationCallback(self.id, funcName)
end
function GetCurMonthThursdaysCount()
   local curTime = os.time()
   local countThursdays = 0
   for i=1,os.date("*t", curTime).day do
      curTime = curTime - 24*60*60
      if os.date("*t", curTime).wday == 5 then 
         countThursdays = countThursdays + 1 
      end
   end
   -- PrintDbgStr(countThursdays.." четвергов прошло в этом мес€це")
   return countThursdays
end

function IsMonthOptionWeekNow()
   return GetCurMonthThursdaysCount() == 2
end

RiOptMan = {}

function RiOptMan:new(obj)
   obj = obj or {}
   setmetatable(obj, self)
   self.__index = self

   obj.options = {}
   return obj
end

function RiOptMan:init(  )
   assert(self.baseTicker, "RiOptions.baseTicker not init")
   assert(self.optClass, "RiOptions.optClass not init")
   local needBaseCodeName = self.baseTicker:sub(1,2)
   local needBaseYear = self.baseTicker:sub(4)
   local optionsCsvStr = getClassSecurities(self.optClass)
   local getBaseAndYearPattern = "(%a%a)[%d%.]+%a%a(%d)"
   PrintDbgStr("ќтобраны опцы:")
   for optionName in string.gmatch(optionsCsvStr, '[^,]+') do
      local baseCodeName, year = string.match( optionName, getBaseAndYearPattern )  
      if baseCodeName == needBaseCodeName and year == needBaseYear then
         local result = ParamRequest(self.optClass, optionName, "strike")
         result = result and ParamRequest(self.optClass, optionName, "expdate")
         result = result and ParamRequest(self.optClass, optionName, "optiontype")
         result = result and ParamRequest(self.optClass, optionName, "days_to_mat_date")
         -- PrintDbgStr(tostring(result))
         if result then
            local option ={
               name = optionName,
               strike = getParamEx2(self.optClass, optionName, "strike").param_image,
               expireDate = getParamEx2(self.optClass, optionName, "expdate").param_image,
               type = getParamEx2(self.optClass, optionName, "optiontype").param_image,
               daysToExpire = tonumber(getParamEx2(self.optClass, optionName, "days_to_mat_date").param_value)
            }
            if option.daysToExpire ~= nil and 
               option.daysToExpire > -1 then 
                  table.insert(self.options, option) end
         end
      end
   end
end

function RiOptMan:__tostring (  )
   assert(self.options, "RiOptMan options didnt init")
   local result = ""
   for i,v in ipairs(self.options) do
      result = result..self.options[i].name.." will expire "..self.options[i].expireDate.." days to wait = "..self.options[i].daysToExpire.."\n"
   end
   result = result.."options count = "..tostring(#self.options)
   return result
end
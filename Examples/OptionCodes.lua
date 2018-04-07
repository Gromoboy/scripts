function OptionBuyTable:GetNearestOptions(strike)
   -- optionsCsvString, strike
   --def
   assert(type(strike) == "string" or 
          type(strike) == "number", 
   "func GetNearestOpt has wrong argument type")

   if type(strike) == "number" then 
      strike = tostring(strike)
   end
   --end def
   --local optionsCsv = getClassSecurities(self.optionClass)
   local optionCall, optionPut
   local optWeekCode = ""
   local countThursday = 0
   local count = 0
   local curTime = os.time()
   for i=1,os.date("*t", curTime).day do
      curTime = curTime - 24*60*60
      if os.date("*t", curTime).wday == 5 then 
         countThursday = countThursday + 1 
      end
   end
   --message(tostring(countThursday))
   if     countThursday == 0 then 
      optWeekCode ="A"
      self.optionClass = "OPTW"
   elseif countThursday == 1 then 
      optWeekCode ="B"
      self.optionClass = "OPTW"
   elseif countThursday == 2 then 
      self.optionClass = "SPBOPT"
   elseif countThursday == 3 then 
      optWeekCode ="D"
      self.optionClass = "OPTW"
   elseif countThursday == 4 then 
      optWeekCode ="E" 
      self.optionClass = "OPTW"
   end

   self.feedOptn.classCode = self.optionClass
   local optionsCsv = getClassSecurities( self.optionClass ) 
   -- Взять из недельных опционов ММВБ или месячных Фортс
   for word in string.gmatch( optionsCsv, '([^,]+)' ) do
      if string.find(word, strike, 1, true) ~= nil then
         
         if word:sub(-1) == optWeekCode or optWeekCode == ""  then 
            if count == 0 then
               optionCall = word
               count = count + 1
            else 
               optionPut = word
               break
            end
         end
      end
   end
   --message(args.optionsCsvString)
   return optionCall, optionPut--, countThursday
end
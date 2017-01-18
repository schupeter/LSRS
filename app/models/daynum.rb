class Daynum
  def self.deleap(day,year)
    # turn a day number from a leap year into a day number for a standard year 
		if Date.leap?(year) and day > 90 then
			day - 1
		else
			day
		end
  end
end 

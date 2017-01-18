class Calculate

  # Generic sum method for Array
  # class agnostic, so it works on numbers or concatenates strings
  class Array; def sum; inject( nil ) { |sum,x| sum ? sum+x : x }; end; end

  def Calculate.perdecim(percentArray)
    # given an array containing four percentage values which total 100, 
    # calculate equivalent perdecim values
    perdecimArray = [0,0,0,0]
    for i in 0..3
      perdecimArray[i] = ( percentArray[i] / 10.0).round
    end
    perdecimArraySum = perdecimArray.sum.to_f
    if perdecimArraySum != 10 then # ensure sum = 10
      diffArray = [0,0,0,0]
      absArray = [0,0,0,0]
      for i in 0..3
        if percentArray[i] == 0 then
          absArray[i] = 0
          diffArray[i] = 0
        else
          absArray[i] = ((percentArray[i] - perdecimArray[i] * 10.0) / percentArray[i]).abs
          diffArray[i] = ((percentArray[i] - perdecimArray[i] * 10.0) / percentArray[i]) / absArray[i]
        end
      end
      perdecimArray[absArray.index(absArray.max)] = perdecimArray[absArray.index(absArray.max)] + diffArray[absArray.index(absArray.max)].to_i
    end
    return perdecimArray
  end
  
  # Calculate.constrain
  # restricts a value (value) to within an allowable range (min, max)
  def Calculate.constrain(value, min, max)
    if value > max then value = max end
    if value < min then value = min end
    return value
  end

  # Calculate.lesser
  # returns the maximum value of a pair of values
  def Calculate.lesser(a, b)
    if a < b then
      return a
    else
      return b
    end
  end

  # Calculate.greater
  # returns the maximum value of a pair of values
  def Calculate.greater(a, b)
    if a > b then
      return a
    else
      return b
    end
  end

  # Calculate.rating - rename this to Calculate.suitability_class
  # converts an LSRS point value to a rating
  def Calculate.rating(value)
    if value >= 80 then
      rating = 1
    elsif value >= 60 then
      rating = 2
    elsif value >= 45 then
      rating = 3
    elsif value >= 30 then
      rating = 4
    elsif value >= 20 then
      rating = 5
    elsif value >= 10 then
      rating = 6
    else
      rating = 7
    end
    return rating
  end

  #Calculate.apply_hash
  # takes as input an array and a hash.
  # transforms the contents of the array according to the hash.
  def Calculate.apply_hash(input, hash)
    return input.map { |x| hash[x] }
  end

  #Calculate.cmp_uniq
  # takes as input an array whose elements consist of [ Value, Percent ]
  # returns a hash where Percent is summarized for Value
  def Calculate.cmp_uniq(inputArray)
    outputHash = Hash.new
    for x in inputArray
      if outputHash[x[0]] == nil
        outputHash.store(x[0], x[1])
      else
        outputHash.store(x[0], ( outputHash[x[0]] + x[1] ) )
      end
    end
    return outputHash
  end
  
  # Calculate.cmp_uniq_sorted
  # takes as input an array whose elements consist of [ Value, Percent ]
  # returns an array where Percent is summarized for Value, and highest percentages appear first
  def Calculate.cmp_sorted_uniq(inputArray)
    inputArrayUniq = Calculate.cmp_uniq(inputArray).to_a
    uniqPercentagesArray = inputArrayUniq.map{|item| item[1]}.uniq.sort.reverse
    outputArray = Array.new
    for x in uniqPercentagesArray do
      outputArray = outputArray + inputArrayUniq.find_all{|item| item[1] == x}
    end
    return outputArray
  end

  def Calculate.cmp_sum_of(inputArray, value)
    [value, inputArray.find_all{|item| item[0] == value}.inject(0){|sum, item| sum + item[1]}]
  end

	# Calculate.interpolation
	# calculates a value for a key from an ordered Hash using linear interpolation
	# value is the point being requested
	# hash is a deductions hash in ascending order.  e.g. {3=>14, 4=>18, 5=>60}, which is created from a sorted deductions array of hashes e.g. [ {:value=>0, :deduction=>0}, {:value=>50, :deduction=>10} ]
	def Calculate.interpolate(value, deductions)
		hash = deductions.map{|x|[x[:value],x[:deduction]]}.to_h
		if hash[value] != nil then 
			return hash[value]
		elsif hash.first[0] > value then 
			return hash.first[1]
		elsif hash.keys.last < value then
			return hash.values.last
		else
			hash.each_cons(2) do |lower,upper|
				if lower[0] <= value and upper[0] >= value then
					return lower[1].to_f + ((upper[1]-lower[1]).to_f*(value-lower[0]).to_f/(upper[0]-lower[0]).to_f)
				end
			end
		end
	end
	
	# Look up value in table, and linearly interpolate if there's no exact match.
	# The first argument is the value to look up. The second is the lookup table
	# table is a vector (array) of numeric key/value subarray pairs, sorted by key
	def Calculate.lookup(key, table)
	#table = table.to_a if table.is_a? Hash  # allow use of Hashes
	#table.sort! { |x,y| x[0] <=> y[0] }     # allow use of unsorted arrays
		b = table.bsearch { |x| x[0] >= key } || table.last
		index_b = table.index(b)
		a = if index_b > 0 then table[index_b - 1] else b end

		return a[1] if key <= a[0]
		return b[1] if key >= b[0]

		key_difference = b[0] - a[0]
		value_difference = b[1] - a[1]
		proportion = (key - a[0]).to_f / key_difference
		a[1] + ( value_difference * proportion)
	end

end

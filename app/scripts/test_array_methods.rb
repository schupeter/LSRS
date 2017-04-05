
class Array
  #sum (and mean) found on http://snippets.dzone.com/posts/show/2161
  def sum
    inject( nil ) { |sum,x| sum ? sum + x.to_f : x.to_f }
  end

  def mean
    sum.to_f / size
  end
  
  #http://en.wikipedia.org/wiki/Mean#Weighted_arithmetic_mean
  def weighted_mean(weights_array)
    raise "Each element of the array must have an accompanying weight.  Array length = #{self.size} versus Weights length = #{weights_array.size}" if weights_array.size != self.size
    w_sum = weights_array.sum
    w_prod = 0
    self.each_index {|i| w_prod += self[i] * weights_array[i].to_f}
    w_prod.to_f / w_sum.to_f
  end
end

#1. Summing elements: This is a fairly common task. We'll use Ruby's inject method to sum all the items in the array and then print out the sum:

puts my_array.inject(0){|sum,item| sum + item}

#2. Double every item: This is a class of problem where we want to preform an operation on every element of the array. 
#Again, this is fairly simple using Ruby's map method. Think of performing a "mapping" from the first array to the second 
#based on the function in the block. Keep in mind, this will return a new array and will NOT affect the original array. 
#If we want to do a destructive map (change the initial array) we would use map!. This is a common convention in Ruby:

my_array.map{|item| item*2 }

#3. Finding all items that meet your criteria: If you want to collect all the values in the array that meet some criteria, 
#we can do this using the (duh) find_all method. Again, this will return an array. The code below finds all items that are multiples of three:

my_array.find_all{|item| item % 3 == 0 }

4. Combine techniques: Let''s now say we want to find the sume of all elements in our array that are multiples of 3. Ruby to the rescue! This is very simple because we can chain methods together gracefully in Ruby. Check it out:

my_array.find_all{|item| item % 3 == 0 }.inject(0){|sum,item| sum + item }

5. Sorting: We can sort items in an array quite easily. Below, I will show the standard sort and then a sort based on the negative value of the number. Both are so simple, my head just exploded:

my_array.sort
my_array.sort_by{|item| item*-1}


======================================================


require "lsrs_calculate"
inputArray = Array.new
inputArray = [["a", 10], ["b", 30], ["a", 25], ["c",10], ["c",25], ["d",40]]
inputArray.find_all{|item| item[0] == "c"}           # finds all rows with Value = "c"
Calculate.cmp_uniq(inputArray)                           # turns inputArray into a hash 

inputArrayUniq = Calculate.cmp_uniq(inputArray).to_a
uniqPercentagesArray = inputArrayUniq.map{|item| item[1]}.uniq.sort.reverse
outputArray = Array.new
for x in uniqPercentagesArray do
  outputArray = outputArray + inputArrayUniq.find_all{|item| item[1] == x}
end





=======================================================
Ruby: Extended Arrays & Hashes (arrayx) (See related posts)

require 'set'

class Array

# Performs delete_if and returns the elements deleted instead (delete_if will return the array with elements removed).
# Because it is essentially delete_if, this method is destructive. Also this method is kinda redundant as you can simply
# call dup.delete_if passing it the negation of the condition.

def delete_fi
  x = select { |v| v if yield(v) }
  delete_if { |v| v if yield(v) }
  x.empty? ? nil : x
end

# Turns array into a queue. Shifts proceeding n elements forward
# and moves the first n elements to the back. When called with
# a block, performs next! and returns the result of block
# performed on that new first element. This method is destructive.

# a = [1,2,3].next!  => [2,3,1]
# a.next! { |x| x+ 10 } => 13
# a is now [3,1,2]

def next!(n=1)
  n.times do
    push(shift)
  end
  if block_given?
    y = yield(first)
    y
  else
    self
  end
end

# Treats [x,y] as a range and expands it to an array with y elements
# from x to y.

# [1,10].expand => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
# [1,10].expand { |x| x**2 } => [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]

def expand
  x = (first..last).to_a
  if block_given?
    x.collect { |x| yield(x) }
  else
    x
  end
end

def shuffle!
   each_index do |i|
     j = rand(length-i) + i
     self[j], self[i] = self[i], self[j]
   end
end

def pick(n=1)
  y = Set.new
  until y.size == n
    t = self[rand(size)]
    y.add(t)
  end
  y.to_a
  y.to_a.first if n == 1
end

# ======== MATRIX CRUD ========= #

# Turns [x,y] into a matrix with x rows and y columns and fills them
# with the result of block. Block must be given *without* arguments.
# If no block is given, the method yields a sparse matrix.

# m = [3,3].to_matrix { rand(30) }
# => [[20, 26, 5, 14, 10], [20, 0, 28, 21, 18], [21, 16, 20, 12, 11]]

def to_matrix
  row = first
  col = last
  if block_given?
    x = Array.new(row) { Array.new(col) { yield } }
  else
    x = Array.new(row) { Array.new(col,0) }
  end
  x
end

def each_coordinate
  each_with_index do |row,x|
    row.each_with_index do |col,y|
      yield(x,y)
    end
  end
end

def mx_lookup(row,col)
  if row < 0 || col < 0
    nil
  else
    self[row][col]
  end
end

def mx_assign(row,col,val)
  self[row][col] = val
end

def mx_update(row,col,new_val)
  self[row][col] = new_val
end

end

class Hash

# Performs delete_if and returns the elements deleted. Because
# it is essentially delete_if, this method is destructive.

def delete_fi
  x = select { |k,v| yield(k,v) }
  delete_if { |k,v| yield(k,v) }
  x.empty? ? nil : x
end

def collect
  x = select { |k,v| yield(k,v) }
  h = x.inject({}) { |h,v| h.update x.first => x.last }
  h
end

end

class Range
  
# Returns an array with n random numbers within range.
  
	def pick(n=1)
    y = []
	  x = [first,last].expand
	  n.times { y << x[rand(x.size)] }
    y
    y.first if n == 1
	end
	
end


============================================================================================

require 'arrayx' # separate post

# Statistical methods for arrays. Also see NArray Ruby library.

class Float

  def roundf(decimal_places)
      temp = self.to_s.length
      sprintf("%#{temp}.#{decimal_places}f",self).to_f
  end

end

class Integer

  # For easy reading e.g. 10000 -> 10,000 or 1000000 -> 100,000
  # Call with argument to specify delimiter.

  def ts(delimiter=',')
    st = self.to_s.reverse
    r = ""
    max = if st[-1].chr == '-'
      st.size - 1
    else
      st.size
    end
    if st.to_i == st.to_f
      1.upto(st.size) {|i| r << st[i-1].chr ; r << delimiter if i%3 == 0 and i < max}
    else
      start = nil
      1.upto(st.size) {|i|
        r << st[i-1].chr
        start = 0 if r[-1].chr == '.' and not start
        if start
          r << delimiter if start % 3 == 0 and start != 0  and i < max
          start += 1
        end
      }
    end
    r.reverse
  end

end

class Array

  def sum
    inject( nil ) { |sum,x| sum ? sum+x : x }
  end

  def mean
    sum=0
    self.each {|v| sum += v}
    sum/self.size.to_f
  end

  def variance
    m = self.mean
    sum = 0.0
    self.each {|v| sum += (v-m)**2 }
    sum/self.size
  end

  def stdev
    Math.sqrt(self.variance)
  end

  def count                                 # => Returns a hash of objects and their frequencies within array.
    k=Hash.new(0)
    self.each {|x| k[x]+=1 }
    k
  end
    
  def ^(other)                              # => Given two arrays a and b, a^b returns a new array of objects *not* found in the union of both.
    (self | other) - (self & other)
  end

  def freq(x)                               # => Returns the frequency of x within array.
    h = self.count
    h(x)
  end

  def maxcount                              # => Returns highest count of any object within array.
    h = self.count
    x = h.values.max
  end

  def mincount                              # => Returns lowest count of any object within array.
    h = self.count
    x = h.values.min
  end

  def outliers(x)                           # => Returns a new array of object(s) with x highest count(s) within array.
    h = self.count                                                              
    min = self.count.values.uniq.sort.reverse.first(x).min
    h.delete_if { |x,y| y < min }.keys.sort
  end

  def zscore(value)                         # => Standard deviations of value from mean of dataset.
    (value - mean) / stdev
  end

end


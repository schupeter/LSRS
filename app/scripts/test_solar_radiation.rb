#!/usr/bin/ruby
#*********************************************************************************************
#Purpose: This function calculates day length and the solar radiation in the upper atmosphere.
# Origin and original formulas are unknown.  
# These values are about 3% higher than the FAO formula
# Code translated from Fortran to C++ to Java to Ruby
#*********************************************************************************************
latdd = 49.27
nday = 0
max = 0.0
min = 25.0

if latdd < 66 then
    phi = latdd / 57.29578
    photp = Array.new(366)
    rad = Array.new(13)
    rstop = Array.new(366)
    while nday < 365 do
        f = 60.0
        nday += 1
        theta = 0.01721*nday
        delta = 0.3964 + 3.631*Math.sin(theta)-22.97*Math.cos(theta)+0.03838*Math.sin(2*theta)-0.3885*Math.cos(2*theta)+0.07659*Math.sin(3*theta)-0.1587*Math.cos(3*theta)-0.01021*Math.cos(4*theta);
        delta = delta / 57.29578;
        daylen = Math.acos((-0.01454-Math.sin(phi)*Math.sin(delta))/(Math.cos(phi)*Math.cos(delta)));
        daylen = daylen*7.639;
        photp[nday] = daylen;
        r = 1.0 - 0.0009464 * Math.sin(theta) - 0.00002917 * Math.sin(3 * theta) - 0.01671 *  Math.cos(theta) - 0.0001489 * Math.cos(2 * theta) - 0.00003438 * Math.cos(4 * theta)
        ourmax = Math.acos(-0.01454 - Math.sin(phi) * Math.sin(delta) / (Math.cos(phi) * Math.cos(delta)))
        ormax = Math.acos( -Math.sin(phi) * Math.sin(delta) / (Math.cos(phi) * Math.cos(delta)))
        solar = 0.0
        oour = 0.0
        i = 1
        our = oour + 6.2832/24.0
        x = 1
        while x == 1 do
      x = 0
            cosoz = (Math.sin(phi) * Math.sin(delta)) + (Math.cos(phi) * Math.cos(delta) * Math.cos(oour))
            cosz = (Math.sin(phi) * Math.sin(delta)) + (Math.cos(delta) * Math.cos(phi) * Math.cos(our))
            rad[i] = f * 2.0 * (cosoz+cosz)/(2*r*r)
            solar = solar + 2 * rad[i]
            i = i + 1
            if f >= 60 then
                x = 1
                oour = our
                our = oour + 6.2832/24.0
                if our-ormax > 0 then
                    our = ormax
                    f = 60.0 * (ourmax-oour) * 24.0 / 6.2832
                end
            end
        end
        rstop[nday] = solar
        puts "day #{nday}: #{photp[nday]}: rstop = #{rstop[nday]}"
    end
else
    photp = Array.new(365,0.0)
end

#photp.each{|p| puts p}
puts
puts "photp.size = #{photp.size}"
#puts "min = #{min}"
#puts "dmin = #{dmin}"
#puts "max = #{max}"
#puts "maxd = #{dmax}"
#puts 


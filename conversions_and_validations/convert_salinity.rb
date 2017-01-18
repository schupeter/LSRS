# Salinity
#  LSRSv4 formula for all crops (???)
class Salinity
def Salinity.calc(subsurfaceSalinity)
Calculate.constrain( (-20 + 5.375 * subsurfaceSalinity), 0, 100)
end
end
Salinity.calc(3.325)

class Salinity
def Salinity.lookup(subsurfaceSalinity)
Calculate.lookup(subsurfaceSalinity, DEDUCTIONS["sssgrain"][:subsurfaceSalinity])
end
end

DEDUCTIONS["sssgrain"][:subsurfaceSalinity]

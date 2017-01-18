# PPE 
#  LSRSv4 formula for canola and sssgrain:
class Ppe
def Ppe.calc(ppe)
aa = -27.304
ab = -0.195
aa + (ab * ppe)
end
end
Ppe.calc(-650)
Ppe.calc(-499)
Ppe.calc(-396)
Ppe.calc(-294)
Ppe.calc(-140)

#  LSRSv4 formula for alfalfa and brome:
class Ppe
def Ppe.calc(ppe)
aa = -30
ab = -0.2
aa + (ab * ppe)
end
end
Ppe.calc(-650)
Ppe.calc(-500)
Ppe.calc(-400)
Ppe.calc(-300)
Ppe.calc(-150)


#  LSRSv4 formula for corn:
class Ppe
def Ppe.calc(ppe)
aa = -10
ab = -0.2
aa + (ab * ppe)
end
end
Ppe.calc(-550)
Ppe.calc(-400)
Ppe.calc(-300)
Ppe.calc(-200)
Ppe.calc(-50)

#  LSRSv4 formula for soybean:
class Ppe
def Ppe.calc(ppe)
aa = -20
ab = -0.2
aa + (ab * ppe)
end
end
Ppe.calc(-600)
Ppe.calc(-450)
Ppe.calc(-350)
Ppe.calc(-250)
Ppe.calc(-100)

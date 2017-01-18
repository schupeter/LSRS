#Alfalfa
class Gsl
def Gsl.calc(gsl)
hf2a = 72.05
hf2b = 0.2889
hf2c = -0.0026
hf2a + ( hf2b * gsl ) + ( hf2c * gsl ** 2 )
end
end
Gsl.calc 5 # formula give 73, but should be 90
Gsl.calc 61 
Gsl.calc 118 
Gsl.calc 154 
Gsl.calc 208  
Gsl.calc 231  

 

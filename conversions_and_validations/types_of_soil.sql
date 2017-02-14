# examples for triage in Fieldcrop1.rate_soil

# folic humisol
SELECT soil_name_canada_v2.soil_id, soil_name_canada_v2.g_group3, soil_name_canada_v2.s_group3
FROM soil_name_canada_v2
WHERE g_group3 = "FO" and s_group3 = "HU"; 

	e.g 	BCDNN~~~~~N


# normal organic
SELECT soil_name_canada_v2.soil_id, soil_name_canada_v2.kind
FROM soil_name_canada_v2
WHERE kind = "O"; 

	ABABNaa~~~N


# unclassified soil WORKS
SELECT soil_name_canada_v2.soil_id, soil_name_canada_v2.kind
FROM soil_name_canada_v2
WHERE kind = "U"; 

http://lsrs.soilinfo.ca/lsrs5/crop/alfalfa/site/ABZBR~~~~~N/1/-161/1.2/100/0.01/details.html

# normal mineral soil WORKS

http://lsrs.soilinfo.ca/lsrs5/crop/alfalfa/site/ABBWV~~~~~N/1/-161/1.2/100/0.01/details.html


# missing layer data
SELECT soil_name_canada_v2.soil_id, soil_name_canada_v2.soil_code, soil_layer_canada_v2.layer_no
FROM soil_name_canada_v2
LEFT JOIN soil_layer_canada_v2
ON soil_name_canada_v2.soil_id=soil_layer_canada_v2.soil_id 
WHERE layer_no is null; 

	http://lsrs.soilinfo.ca/lsrs5/crop/alfalfa/site/ONPIT~~~~~N/1/-161/1.2/100/0.01/details.html

# missing name data

	http://lsrs.soilinfo.ca/lsrs5/crop/alfalfa/site/ONXXXxxxxxN/1/-161/1.2/100/0.01/details.html

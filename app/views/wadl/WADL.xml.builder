xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.instruct! "xml-stylesheet", :type=>"text/xsl", :href=>"/schemas/wadl/1.0/stylesheets/wadl_en.xsl"
xml.tag!("wadl:application", 
"xmlns:wadl".to_sym => "http://wadl.dev.java.net/2009/02", 
"xmlns:xsi".to_sym => "http://www.w3.org/2001/XMLSchema-instance", 
"xsi:schemaLocation".to_sym => "http://wadl.dev.java.net/2009/02 ../wadl.xsd") do
	xml.tag!("wadl:doc", @application.doc_en,  :title => @application.group_en+" - "+@application.subgroup_en+" - "+@application.title_en)
	if request.host == @application.testing_domain then domain = @application.testing_domain else domain = @application.domain end
	xml.tag!("wadl:resources", :base => ("http://"+domain+@application.path) ) do
		for resource in @application.webappresources do
			xml.tag!("wadl:resource", :path => resource.path ) do
				xml.tag!("wadl:doc", resource.title_en)
				for method in resource.webappmethods do
					xml.tag!("wadl:method", :name=>method.http, :id=>method.name) do
						xml.tag!("wadl:doc", method.doc_en)
						xml.tag!("wadl:doc")
						for text in method.webappexamples do
							xml.tag!("wadl:doc", text.example, :title=>"Example")
						end
						xml.tag!("wadl:request") do
							for input in method.webapptemplateparams.all do
								xml.tag!("wadl:param", :name=>input.name, :style=>"template", :type=>input.datatype, :required=>"true") do
									xml.tag!("wadl:doc", input.doc_en)
								end
							end
							for input in method.webappqueryparams.all do
								xml.tag!("wadl:param", :name=>input.name, :style=>"query", :type=>input.datatype, :required=>input.required) do
									xml.tag!("wadl:doc", input.doc_en)
								end
							end
						end
						xml.tag!("wadl:response", :status=>"200") do
							xml.tag!("wadl:doc", :title=>"OK")
							for response in method.webappresponses.all do
								xml.tag!("wadl:representation", :mediaType=>response.mediatype) do
									xml.tag!("wadl:doc", response.doc_en, :title=>response.name)
								end
								xml.tag!("wadl.param")
							end
						end
						xml.tag!("wadl:response", :status=>"404") do
							xml.tag!("wadl:doc", :title=>"Not Found")
						end
					end
				end
			end
		end
	end
end

xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone=>"no"
xml.ExceptionReport do
  xml.Exception do
    xml.Code(@exceptionCode) if @exceptionCode != nil
    xml.Parameter(@exceptionParameter) if @exceptionParameter != nil
    xml.ParameterValue(@exceptionParameterValue) if @exceptionParameterValue != nil
    xml.Text(@exceptionText) if @exceptionText != nil
  end
end
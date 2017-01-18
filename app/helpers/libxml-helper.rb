require "xml/libxml"
class XML::Node
  ##
  # Open up XML::Node from libxml and add convenience methods inspired
  # by hpricot.
  # (http://code.whytheluckystiff.net/hpricot/wiki/HpricotBasics)
  # Also:
  #  * provide better handling of default namespaces
	# added text_at PS 20100926
	#
  # an array of default namespaces to past into
  attr_accessor :default_namespaces
  # find the child node with the given xpath
  def at(xpath)
	self.find_first(xpath)
  end
  # find the content of a text element or attribute with the given xpath, return an empty string if xpath not found
	def text_at(xpath)
		results = self.find_first(xpath)
		if results.nil? then string = ""  else
			if results.class == LibXML::XML::Attr then string = results.value else string = results.content end
		end
		return string
	end
	# find the array of child nodes matching the given xpath
  def search(xpath)
	results = self.find(xpath).to_a
	if block_given?
	  results.each do |result|
		yield result
	  end
	end
	return results
  end
  # alias for search
  def /(xpath)
	search(xpath)
  end
  # return the inner contents of this node as a string
  def inner_xml
	child.to_s
  end
  # alias for inner_xml
 def inner_html
	inner_xml
  end
  # return this node and its contents as an xml string
  def to_xml
	self.to_s
  end
  # alias for path
  def xpath
	self.path
  end
  # provide a name for the default namespace
  def register_default_namespace(name)
	self.namespaces.to_a.each do |n|
	  if n.prefix == nil
		register_namespace("#{name}:#{n.href}")
		return
	  end
	end
	raise "No default namespace found"
  end
  # register a namespace, of the form "foo:http://example.com/ns"
  def register_namespace(name_and_href)
	(@default_namespaces ||= []) <<name_and_href
  end
  def find_with_default_ns(xpath_expr, namespace=nil)
	find_base(xpath_expr, namespace || default_namespaces)
  end
  def find_first_with_default_ns(xpath_expr, namespace=nil)
	find_first_base(xpath_expr, namespace || default_namespaces)
  end
  alias_method :find_base, :find unless method_defined?(:find_base)
  alias_method :find, :find_with_default_ns
  alias_method :find_first_base, :find_first unless method_defined?(:find_first_base)
  alias_method :find_first, :find_first_with_default_ns
end
class String
  def to_libxml_doc
	xp = XML::Parser.string(self)
	return xp.parse
  end
end


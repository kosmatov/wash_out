xml.instruct!
xml.definitions 'xmlns' => 'http://schemas.xmlsoap.org/wsdl/',
                'xmlns:tns' => @namespace,
                'xmlns:soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
                'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
                'xmlns:soap-enc' => 'http://schemas.xmlsoap.org/soap/encoding/',
                'xmlns:wsdl' => 'http://schemas.xmlsoap.org/wsdl/',
                'name' => @name,
                'targetNamespace' => @namespace do

  xml.types do
    xml.tag! "schema", :targetNamespace => @namespace, :xmlns => 'http://www.w3.org/2001/XMLSchema' do
      defined = []
      @map.each do |operation, formats|
        wsdl_operation_element xml, operation, formats, defined
      end
    end
  end

  @map.each do |operation, formats|
    xml.message :name => "#{operation}" do
      xml.part :name => "parameters", :element => "tns:#{operation}"
    end

    xml.message :name => formats[:response_tag] do
      xml.part :name => "parameters", :element => "tns:#{formats[:response_tag]}"
    end
  end

  xml.portType :name => "#{@name}_port" do
    @map.each do |operation, formats|
      xml.operation :name => operation do
        xml.input :message => "tns:#{operation}"
        xml.output :message => "tns:#{formats[:response_tag]}"
      end
    end
  end

  xml.binding :name => "#{@name}_binding", :type => "tns:#{@name}_port" do
    xml.tag! "soap:binding", :style => 'document', :transport => 'http://schemas.xmlsoap.org/soap/http'
    @map.keys.each do |operation|
      xml.operation :name => operation do
        xml.tag! "soap:operation", :soapAction => operation
        xml.input do
          xml.tag! "soap:body",
            :use => "literal",
            :namespace => @namespace
        end
        xml.output do
          xml.tag! "soap:body",
            :use => "literal",
            :namespace => @namespace
        end
      end
    end
  end

  xml.service :name => "service" do
    xml.port :name => "#{@name}_port", :binding => "tns:#{@name}_binding" do
      xml.tag! "soap:address", :location => send("#{@name}_action_url")
    end
  end

end

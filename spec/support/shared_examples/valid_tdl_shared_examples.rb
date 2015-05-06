shared_examples_for "valid tdl" do
  let(:xsd_schema_file) { File.expand_path("../TDL.xsd", __FILE__) }
  let(:xsd_schema) { Nokogiri::XML::Schema(File.read(xsd_schema_file)) }

  it "should be valid TDL document" do
    xsd_schema.validate(subject).should == []
  end
end

require 'spec_helper'

describe String do
  it "should translate true strings" do
    %w(True T t true Yes yes Y y 1).all? { |v| v.to_bool.should be_true }
  end

  it "should translate false strings" do
    %w(False F f false No no n N 0).all? { |v| v.to_bool.should be_false }
  end

  it "should rase an exception for unknown strings" do
    lambda { "JarjarBinks".to_bool }.should raise_exception
  end
end

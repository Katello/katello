node :applicable_consumers do |e|
  Katello::System.where(:uuid => e.applicable_consumers).select([:name, :uuid]).collect{|i| {:name=> i.name, :uuid => i.uuid}}
end

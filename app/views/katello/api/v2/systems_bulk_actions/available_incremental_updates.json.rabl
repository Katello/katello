collection @collection

child :content_view_version => :content_view_version do
  attributes :name, :id, :version
end

child :environments => :environments do
  attributes :name, :id
end

attributes :next_version

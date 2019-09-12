object Katello::Util::Data.ostructize(@resource)

attribute :status
child :services => :services do
  Katello::Ping.services.each do |service|
    child service => service do
      attribute :status
      attribute :message
      attribute :duration_ms
    end
  end
end

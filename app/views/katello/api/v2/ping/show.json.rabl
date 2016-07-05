object Katello::Util::Data.ostructize(@resource)

attribute :status
child :services => :services do
  Katello::Ping::SERVICES.each do |service|
    child service => service do
      attribute :status
      attribute :duration_ms
    end
  end
end

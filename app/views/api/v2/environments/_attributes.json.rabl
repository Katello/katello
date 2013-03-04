attributes :id, :created_at, :name, :description, :prior_id, :label, :updated_at, :organization_id, :library
node(:prior) { |e| e.prior.name if e.prior }
node(:organization) { |e| e.organization.name }

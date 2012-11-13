module Authorization::ContentView
  READ_PERM_VERBS = [:read, :promote, :subscribe]

  def self.included(base)
    base.extend ClassMethods
  end

  def readable?
    User.allowed_to?(READ_PERM_VERBS, :content_views, self.id, self.organization)
  end

  def promotable?
    User.allowed_to?([:promote], :content_views, self.id, self.organization)
  end

  def subscribable?
    User.allowed_to?([:subscribe], :content_views, self.id, self.organization)
  end

  module ClassMethods

    def tags(ids)
      select('id, name').where(:id => id).map do |v|
        VirtualTag.new(v.id, v.name)
      end
    end

    def list_tags(org_id)
      custom.select('id, name').where(:organization_id => org_id).map do |v|
        VirtualTag.new(v.id, v.name)
      end
    end

    def list_verbs(global = false)
      {
        :read => _("Read Content Views"),
        :promote => _("Promote Content Views"),
        :subscribe => _("Subscribe Systems To Content Views")
      }.with_indifferent_access
    end

    def read_verbs
      [:read]
    end

    def no_tag_verbs
      []
    end

    def any_readable?(org)
      User.allowed_to?(READ_PERM_VERBS, :content_views, nil, org)
    end

    def readable(org)
      items(org, READ_PERM_VERBS)
    end

    def promotable(org)
      items(org, [:promote])
    end

    def subscribable(org)
      items(org, [:subscribe])
    end

    def promotable(org)
      items(org, [:promote])
    end

    def items(org, verbs)
      raise "scope requires an organization" if org.nil?
      resource = :content_views

      if User.allowed_all_tags?(verbs, resource, org)
        where(:organization_id => org.id)
      else
        where("content_views.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
      end
    end
  end
end

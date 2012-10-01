class Resources::ForemanModel < Resources::AbstractModel

  def self.resource
    super or Resources::Foreman.const_get to_s.demodulize
  rescue NameError => e
    if e.message =~ /Resources::Foreman::#{to_s.demodulize}/
      raise "could not find Resources::Foreman::#{to_s.demodulize}, try to set the resource with #{to_s}.set_resource"
    else
      raise e
    end
  end

  def self.header
    raise 'current user is not set' unless (user = get_current_user)
    super.merge :foreman_user => user.username
  end

  protected

  def parse_errors(hash)
    hash[resource_name]['errors']
  end

end




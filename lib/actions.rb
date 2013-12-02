module Actions
  require 'actions/world'
  require 'actions/delayed_worker_injector'
  require 'actions/base'

  def self.world
    base.world
  end

  def self.trigger(action, *args, &block)
    base.trigger action, *args, &block
  end

  def self.base
    @base ||= Base.new
  end
end

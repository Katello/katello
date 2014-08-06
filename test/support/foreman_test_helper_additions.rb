Organization.class_eval do
  def ensure_not_in_transaction!
  end

  def execute_planned_action
  end
end

User.class_eval do
  def ensure_not_in_transaction!
  end

  def execute_planned_action
  end
end

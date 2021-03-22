require 'katello_test_helper'

describe 'KatelloAudit' do
  let(:base_class) { Audited::Audit }
  let(:katello_audit) { KatelloAudit }
  let(:subject) { base_class.new }

  it 'has the same table_name as Audited::Audit' do
    assert_equal base_class.table_name, katello_audit.table_name
  end

  it 'always returns absolute class name' do
    assert_equal katello_audit.name, "::KatelloAudit"
  end

  it 'creates Audited::Audit objects' do
    assert_equal katello_audit.base_class, base_class
  end

  it 'does not add any methods' do
    assert_equal [], (base_class.methods - katello_audit.methods)
  end
end

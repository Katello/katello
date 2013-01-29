#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require './test/models/authorization/authorization_base'


class SystemTemplateAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @template = SystemTemplate.find(system_templates(:simple_template))
    @org = @acme_corporation
  end

  def test_any_readable?
    assert SystemTemplate.any_readable?(@org)
  end

  def test_readable?
    assert SystemTemplate.readable?(@org)
  end

  def test_manageable?
    assert SystemTemplate.manageable?(@org)
  end

  def test_readable
    assert @template.readable?
  end

end


class SystemTemplateAuthorizationNoPermsTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @template = SystemTemplate.find(system_templates(:simple_template))
    @org = @acme_corporation
  end

  def test_any_readable?
    refute SystemTemplate.any_readable?(@org)
  end

  def test_readable?
    refute SystemTemplate.readable?(@org)
  end

  def test_manageable?
    refute SystemTemplate.manageable?(@org)
  end

  def test_readable
    refute @template.readable?
  end

end

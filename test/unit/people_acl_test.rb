require File.expand_path('../../test_helper', __FILE__)

class PeopleAclTest < ActiveSupport::TestCase

  fixtures :users

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/',
                            [:people])


  def test_acl_create
    prepare_acl
    acl = PeopleAcl.create(@u.id, @permissions)
    hash = {@u.id.to_s => @permissions}
    assert_equal hash, acl[:users_acl]
  end

  def test_acl_allowed_to
    prepare_acl
    PeopleAcl.create(@u.id, @permissions)
    acl = PeopleAcl.allowed_to?(@u, @permissions.first)
    assert acl
  end

  def test_acl_without_acls_allowed_to
    prepare_acl
    acl = PeopleAcl.allowed_to?(@u, @permissions.first)
    assert !acl
  end

  private

  def prepare_acl
    @u = User.find(4)
    @permissions = [:view, :read, :delete]
  end

end

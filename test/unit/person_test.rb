require File.expand_path('../../test_helper', __FILE__)

class PersonTest < ActiveSupport::TestCase

  fixtures :users, :roles

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/',
                            [:people])

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_validations_for_internal_users
    p = Person.find(2)
    assert !p.valid?
    assert_include I18n.translate('activerecord.errors.messages.blank'), p.errors[:nickname]
  end

  def test_validations_for_external_users
    p = Person.find(3)
    assert !p.valid?
    assert_include I18n.translate('activerecord.errors.messages.blank'), p.errors[:nickname]
    assert_include I18n.translate('activerecord.errors.messages.blank'), p.errors[:email]
  end

  def test_mobile_phones
    # @mobile_phones || self.mobile_phone ? self.mobile_phone.split( /, */) : []
    p = Person.find(4)
    assert_equal %w[123 234 345], p.mobile_phones
  end

  def test_landline_phones
    # @landline_phones || self.landline_phone ? self.landline_phone.split( /, */) : []
    p = Person.find(4)
    assert_equal %w[123 234 345], p.landline_phones
  end

  def test_internal?
    assert Person.find(2).internal?
    # self.contact_type == 'internal'
  end

  def test_external?
    assert Person.find(3).external?
    # self.contact_type == 'external'
  end

  def test_internal_contractor_email
    email = "text_internal_email@example.com"
    contractor_email = "contractor_email@example.com"
    p = Person.find(2)
    p.email = contractor_email
    p.user = load_user(email)
    assert_equal p.email, email
  end

  def test_external_contractor_email
    email = "text_external_email@example.com"
    contractor_email = "contractor_email@example.com"
    p = Person.find(3)
    p.user = load_user(email)
    p.email = contractor_email
    assert_equal p.email, contractor_email
  end

  def test_available_roles
    assert_kind_of Array, Person.available_roles
    assert_kind_of Role, Person.available_roles.first
  end

  private

    def load_user(email)
      user = User.find(4)
      user.mail = email

      user
    end

end

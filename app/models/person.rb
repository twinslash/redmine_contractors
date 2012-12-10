class Person < ActiveRecord::Base
  unloadable
  self.inheritance_column = :_type_disabled

  include Redmine::SafeAttributes
  acts_as_attachable_global

  STATUS_ANONYMOUS = 0
  GENDERS = [[l(:label_people_male), 0], [l(:label_people_female), 1]]
  CONTACT_TYPES = %W[internal external]
  SEARCH_ATTRS = %w[first_name last_name middle_name nickname email]

  scope :logged_with_status, lambda { |arg| joins{ user.outer }.where { ((user.status != STATUS_ANONYMOUS) & (user.status == arg)) | ((contact_type == 'internal') & (user_id == nil)) | (contact_type == 'external')} }
  scope :in_group, lambda {|group|
    group_id = group.is_a?(Group) ? group.id : group.to_i
    { :conditions => ["#{User.table_name}.id IN (SELECT gu.user_id FROM #{table_name_prefix}groups_users#{table_name_suffix} gu WHERE gu.group_id = ?)", group_id] }
  }
  scope :search_by_name, lambda {|search| where { SEARCH_ATTRS.map { |attr| (__send__(attr) =~ "%#{search}%") }.inject(&:|)} }

  belongs_to :user
  belongs_to :default_role, :class_name => 'Role'
  has_many :memberships, :through => :user
  has_one :avatar, :class_name => "Attachment", :as  => :container, :conditions => "#{Attachment.table_name}.description = 'avatar'", :dependent => :destroy

  validates_presence_of :nickname
  validates_presence_of :email, :if => Proc.new { |person| person.external? }
  validates_uniqueness_of :email, :if => Proc.new { |person| !person.email.blank? }, :case_sensitive => false
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_blank => true

  safe_attributes 'first_name',
                  'middle_name',
                  'last_name',
                  'email',
                  'company',
                  'job_title',
                  'avatar',
                  'nickname',
                  'gender',
                  'birthday',
                  'address',
                  'mobile_phone',
                  'landline_phone',
                  'skype',
                  'github',
                  'facebook',
                  'twitter',
                  'linkedin',
                  'foursquare',
                  'background',
                  'contact_type',
                  'default_role_id'


  def mobile_phones
    @mobile_phones || self.mobile_phone ? self.mobile_phone.split( /, */) : []
  end

  def landline_phones
    @landline_phones || self.landline_phone ? self.landline_phone.split( /, */) : []
  end

  def internal?
    self.contact_type == 'internal'
  end

  def external?
    self.contact_type == 'external'
  end

  def email
    external? ? self.read_attribute(:email) : self.user.try(:mail)
  end

  def self.available_users
    ids = Person.pluck(:user_id).uniq
    User.where { (id << ids) & (type == 'User') }
  end

  def self.available_roles
    Role.all
  end

  def next_birthday
    return if birthday.blank?
    year = Date.today.year
    mmdd = birthday.strftime('%m%d')
    year += 1 if mmdd < Date.today.strftime('%m%d')
    mmdd = '0301' if mmdd == '0229' && !Date.parse("#{year}0101").leap?
    return Date.parse("#{year}#{mmdd}")
  end

  def self.next_birthdays(limit = 10)
    Person.where("people.birthday IS NOT NULL").sort_by(&:next_birthday).first(limit)
  end

  def age
    return nil if birthday.blank?
    now = Time.now
    age = now.year - birthday.year - (birthday.to_time.change(:year => now.year) > now ? 1 : 0)
  end

  def editable_by?(usr, prj=nil)
    true
    # usr && (usr.allowed_to?(:edit_people, prj) || (self.author == usr && usr.allowed_to?(:edit_own_invoices, prj)))
    # usr && usr.logged? && (usr.allowed_to?(:edit_notes, project) || (self.author == usr && usr.allowed_to?(:edit_own_notes, project)))
  end

  def visible?(usr=nil)
    true
  end

  def attachments_visible?(user=User.current)
    true
  end
end

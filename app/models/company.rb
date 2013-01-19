class Company < ActiveRecord::Base
  unloadable

  has_many :people
end

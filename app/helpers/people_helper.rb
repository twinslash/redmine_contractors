module PeopleHelper

  def birthday_date(person)
    if person.birthday.day == Date.today.day && person.birthday.month == Date.today.month
       "#{l(:label_today).capitalize} (#{person.age + 1})"
    else
      "#{person.birthday.day} #{t('date.month_names')[person.birthday.month]} (#{person.age + 1})"
    end
  end

  def person_to_vcard(person)
    require 'vpim/vcard'

    card = Vpim::Vcard::Maker.make2 do |maker|

      maker.add_name do |name|
        name.prefix = ''
        name.given = person.first_name.to_s
        name.family = person.last_name.to_s
        name.additional = person.middle_name.to_s
      end

      maker.add_addr do |addr|
        addr.preferred = true
        addr.street = person.address.to_s.gsub("\r\n"," ").gsub("\n"," ")
      end

      maker.title = person.job_title.to_s
      maker.org = person.company.to_s
      maker.birthday = person.birthday.to_date unless person.birthday.blank?
      maker.add_note(person.background.to_s.gsub("\r\n"," ").gsub("\n", ' '))

      # maker.add_url(person.website.to_s)

      person.mobile_phones.each { |phone| maker.add_tel(phone) }
      person.landline_phones.each { |phone| maker.add_tel(phone) }

      email = person.external? ? person.email : person.user.mail
      maker.add_email(email)
    end
    avatar = person.avatar
    card = card.encode.sub("END:VCARD", "PHOTO;BASE64:" + "\n " + [File.open(avatar.diskfile).read].pack('m').to_s.gsub(/[ \n]/, '').scan(/.{1,76}/).join("\n ") + "\nEND:VCARD") if avatar && avatar.readable?

    card.to_s

  end

  def icon(type)
    "<i class=\"icon-#{type}\"></i> ".html_safe
  end
end

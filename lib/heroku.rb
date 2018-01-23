class Heroku
  def self.enabled?
    Rails.env.development? && ENV['RUNNING_IN_HEROKU'].present?
  end

  def self.create_users(organisation_id)
    organisation = item.find(organisation_id)

    number_of_users = 10
    number_of_users.times do |index|
      User.create!(
        name: "user-#{index}",
        email: "email-#{index}@domain.gov.uk",
        uid: "uid-#{index}",
        organisation_slug: organisation.title.parameterize.underscore,
        organisation_content_id: organisation.content_id,
      )
    end
  end
end

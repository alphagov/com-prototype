class Api::HealthcheckController < ApiController
  skip_before_action :authenticate_user!

  def index
    database = ActiveRecord::Base.connected? ? :ok : :critical

    healthcheck = {
      checks: {
        database: database
      },
      status: :ok
    }

    render json: healthcheck
  end
end
module ApiErrorConcern
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Rescuable
    rescue_from Exception, with: :respond_500
    rescue_from ActionController::RoutingError, with: :respond_404
  end

  private

  def respond_500(exception)
    respond_error(exception.message, 500)
  end

  def respond_404(exception)
    respond_error(exception.message, 404)
  end

  def respond_error(message, status = nil)
    status ||= 400
    render json: { message: message }, status: status
  end
end

class Parties::SessionsController < Devise::SessionsController
  layout 'party'
  before_action :init_meta, only: [:new]

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  private

  def after_sign_out_path_for(_resource_or_scope)
    new_party_session_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) << :identify_number
  end

  def init_meta
    set_meta
  end

end

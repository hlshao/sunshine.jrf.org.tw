class Parties::ConfirmationsController < Devise::ConfirmationsController

  before_action :redirect_new_to_sign_in, only: [:new]
  before_action :check_unconfirmed_email_not_used, only: [:show]

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_flashing_format?
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { redirect_to new_party_session_path }
    end
  end

  protected

  def check_unconfirmed_email_not_used
    party = Party.find_by_confirmation_token(params[:confirmation_token])
    if party && Party.pluck(:email).include?(party.unconfirmed_email)
      set_flash_message(:alert, :conflict_confirmed)
      redirect_to new_party_session_path
    end
  end

  def redirect_new_to_sign_in
    redirect_to new_party_session_path
  end

  def after_resending_confirmation_instructions_path_for(_resource_name)
    party_profile_path
  end

  def after_confirmation_path_for(resource_name, _resource)
    if signed_in?(resource_name)
      party_profile_path
    else
      new_session_path(resource_name)
    end
  end

end

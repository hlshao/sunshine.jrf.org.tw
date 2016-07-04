class Bystander::RegistrationsController < Devise::RegistrationsController
  layout 'bystander'
  include CrudConcern

  before_action :configure_permitted_parameters, if: :devise_controller?

  def update
    context = Bystander::ChangeEmailContext.new(current_bystander)
    prev_unconfirmed_email = current_bystander.unconfirmed_email if current_bystander.respond_to?(:unconfirmed_email)

    if context.perform(params)
      set_flash_message :notice, :update_needs_confirmation
      sign_in :bystander, current_bystander, bypass: true
      respond_with current_bystander, location: after_update_path_for(current_bystander)
    else
      clean_up_passwords resource
      flash.now[:error] = context.error_messages.join(", ")
      render :edit
    end
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    new_session_path(:bystander)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end

  def after_update_path_for(resource)
    bystander_profile_path
  end

end
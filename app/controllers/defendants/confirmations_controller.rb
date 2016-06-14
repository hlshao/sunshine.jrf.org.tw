class Defendants::ConfirmationsController < Devise::ConfirmationsController
  
  before_action :redirect_new_to_sign_in, only: [:new]

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_flashing_format?
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ redirect_to new_defendant_session_path}
    end
  end

  protected

  def redirect_new_to_sign_in
    redirect_to new_bystander_session_path
  end

end
class Party::ChangePhoneFormObject < BaseFormObject
  attr_accessor :unconfirmed_phone
  attr_reader :phone_number

  validates :unconfirmed_phone, format: { with: /\A(0)(9)([0-9]{8})\z/ }, presence: true
  validate :unexist_phone_number, :unexist_unconfirmed_phone

  def initialize(party, params = nil)
    @party = party
    @phone_number = @party.phone_number
    self.unconfirmed_phone = params[:unconfirmed_phone] if params && params[:unconfirmed_phone]
  end

  def save
    return false unless valid?
    @party.update_attributes(unconfirmed_phone: unconfirmed_phone)
  end

  private

  def unexist_phone_number
    if same_phone_number?
      add_error(:phone_number_conflict)
    elsif exist_phone_number?
      add_error(:phone_number_exist)
    end
  end

  def unexist_unconfirmed_phone
    add_error(:phone_number_confirming) if unconfirmed_phone.present? && Party.exists?(unconfirmed_phone: unconfirmed_phone)
  end

  def same_phone_number?
    @party.phone_number == unconfirmed_phone
  end

  def exist_phone_number?
    Party.exists?(phone_number: unconfirmed_phone)
  end

end

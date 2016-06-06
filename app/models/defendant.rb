# == Schema Information
#
# Table name: defendants
#
#  id                     :integer          not null, primary key
#  name                   :string           not null
#  identify_number        :string           not null
#  phone_number           :string
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Defendant < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise authentication_keys: [ :identify_number ]

  validates :name, presence: true
  validates :identify_number, presence: true, uniqueness: true
  validates_format_of :identify_number, with: /\A[A-Z]{1}[1-2]{1}[0-9]{8}\z/, message: "身分證字號格式不符(英文字母請大寫)" 
  validates_format_of :phone_number, with: /\A(0)(9)([0-9]{8})\z/, allow_nil: true 

  has_many :defendant_verdicts
  has_many :verdicts, through: :defendant_verdicts
  has_many :story_relations, as: :people

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def set_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    self.save(validate: false)
    raw
  end
end

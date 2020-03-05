# frozen_string_literal: true

class RecruitmentDocument < HumanResourcesRecord
  attr_readonly :encrypted_email

  # # Validations
  #
  validates :email, presence: true, format: URI::MailTo::EMAIL_REGEXP
  validates :first_name, :last_name, :position, :group, :received_at, :source, :encrypted_email,
            presence: true

  # # Callbacks
  #
  before_validation :encrypt_email

  private

  def encrypt_email
    self.encrypted_email = email.present? ? Digest::SHA512.hexdigest(email) : nil
  end
end

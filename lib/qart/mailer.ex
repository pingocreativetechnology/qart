defmodule Qart.Mailer do
  use Swoosh.Mailer, otp_app: :qart

  def create_email_changeset(attrs) do
    Qart.Forms.ContactForm.changeset(attrs)
  end
end

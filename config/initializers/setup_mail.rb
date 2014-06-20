ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "sidebench.com",
  :user_name            => "bennett@sidebench.com",
  :password             => "papertowel",
  :authentication       => "plain",
  :enable_starttls_auto => true
}
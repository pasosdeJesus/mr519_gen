# frozen_string_literal: true

module Mr519Gen
  class ApplicationMailer < ActionMailer::Base
    default from: "from@example.com"
    layout "mailer"
  end
end

module Mr519Gen
  class ApplicationController < ActionController::Base
    # Sin autorizacion porque es usada por otras
    protect_from_forgery with: :exception
  end
end

# encoding: UTF-8

require 'mr519_gen/concerns/models/campo'

module Mr519Gen
  class Campo < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Campo
  end
end

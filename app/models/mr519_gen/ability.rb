# encoding: utf-8
module Mr519
  class Ability  < Sip::Ability

    BASICAS_PROPIAS = []

    def tablasbasicas
      Sip::Ability::BASICAS_PROPIAS +
        Mimotor::Ability::BASICAS_PROPIAS
    end
  end # class
end  #module

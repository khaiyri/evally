# frozen_string_literal: true

module V2
  module Views
    class EvaluationView < Blueprinter::Base
      association :evaluation, blueprint: V2::EvaluationSerializer, default: {}

      association :sections, blueprint: V2::SectionSerializer, default: []
    end
  end
end

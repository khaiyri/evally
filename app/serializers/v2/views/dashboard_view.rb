# frozen_string_literal: true

module V2
  module Views
    class DashboardView < Blueprinter::Base
      association :employees, blueprint: V2::EmployeeSerializer, default: []

      association :evaluations, blueprint: V2::EvaluationSerializer, default: []

      association :activities, blueprint: V2::ActivitySerializer, default: []
    end
  end
end

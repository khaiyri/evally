# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Section, type: :model do
  it { is_expected.to belong_to(:sectionable) }

  it do
    is_expected.to(
      define_enum_for(:group)
        .with_values(
          rating: 'rating',
          bool: 'bool',
          text: 'text'
        )
        .backed_by_column_of_type(:string)
    )
  end

  it do
    is_expected.to(
      define_enum_for(:width)
        .with_values(
          full: 'full',
          half: 'half'
        )
        .backed_by_column_of_type(:string)
    )
  end

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_presence_of(:group) }

  it { is_expected.to validate_presence_of(:width) }

  it { is_expected.to validate_presence_of(:position) }

  it { should validate_numericality_of(:position).only_integer }

  context 'custom validation' do
    it 'expects to be invalid', :aggregate_failures do
      aggregate_failures 'when skills is not an array' do
        attrs = FactoryBot.attributes_for(:section, skills: 'Lorem ipsum')
        expect(Section.new(attrs)).to be_invalid
      end

      aggregate_failures 'when skilll do not have value' do
        attrs = FactoryBot.attributes_for(:section, skills: [{ name: 'Lorem' }])
        expect(Section.new(attrs)).to be_invalid
      end

      aggregate_failures 'when skilll do not have name' do
        attrs = FactoryBot.attributes_for(:section, skills: [{ value: 10 }])
        expect(Section.new(attrs)).to be_invalid
      end

      aggregate_failures 'when sensitive is nil' do
        attrs = FactoryBot.attributes_for(:section, sensitive: nil)
        expect(Section.new(attrs)).to be_invalid
      end
    end

    it 'expects to be valid' do
      template = FactoryBot.create(:template)

      aggregate_failures 'when sensitive is false' do
        attrs = FactoryBot.attributes_for(:section, sectionable: template, sensitive: false)
        expect(Section.new(attrs)).to be_valid
      end

      aggregate_failures 'when sensitive is true' do
        attrs = FactoryBot.attributes_for(:section, sectionable: template, sensitive: true)
        expect(Section.new(attrs)).to be_valid
      end
    end
  end
end

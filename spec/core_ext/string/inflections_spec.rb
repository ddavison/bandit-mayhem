# frozen_string_literal: true

require 'spec_helper'
require 'core_ext/string/inflections'

module BanditMayhem
  RSpec.describe String do
    describe '#classify' do
      using RSpec::Parameterized::TableSyntax

      where(:string, :expected) do
        'test_class'         | 'TestClass'
        'class'              | 'Class'
        'another_test_class' | 'AnotherTestClass'
      end

      with_them do
        it 'classifies correctly' do
          expect(string.classify).to eq(expected)
        end
      end
    end

    describe '#underscore' do
      using RSpec::Parameterized::TableSyntax

      where(:string, :expected) do
        'TestClass'        | 'test_class'
        'Class'            | 'class'
        'AnotherTestClass' | 'another_test_class'
        'Test Class'       | 'test_class'
      end

      with_them do
        it 'underscores correctly' do
          expect(string.underscore).to eq(expected)
        end
      end
    end
  end
end

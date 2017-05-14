require 'rails_helper'

RSpec.describe Api::ResourcesController::ConditionParser do
  describe 'deep nested conditions' do
    subject { described_class.new('foo', { 'bar' => { 'baz' => 'qux' } }).condition_statement }

    it { expect(subject).to eq({ 'foo' => { 'bar' => { 'baz' => 'qux' }}}) }
  end

  describe 'nested conditions' do
    subject { described_class.new('code_type', {'identifier(eq)' => 'foo' }).condition_statement }

    it { expect(subject).to eq({ 'code_type' => { 'identifier' => 'foo' }}) }
  end

  describe 'simple conditions' do
    subject { described_class.new('code_type(eq)', 'foo').condition_statement }

    it { expect(subject).to eq(["code_type = ?", 'foo']) }
  end
end
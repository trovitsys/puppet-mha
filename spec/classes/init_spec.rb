require 'spec_helper'
describe 'mha' do

  context 'with defaults for all parameters' do
    it { should contain_class('mha') }
  end
end

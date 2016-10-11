require 'spec_helper'
require 'kontena/plugin/upcloud_command'

describe Kontena::Plugin::Upcloud::Nodes::CreateCommand do

  let(:subject) do
    described_class.new(File.basename($0))
  end

  let(:provisioner) do
    spy(:provisioner)
  end

  let(:upcloud_client) do
    spy(:upcloud_client)
  end

  describe '#run' do
    before(:each) do
      allow(subject).to receive(:require_current_grid).and_return('test-grid')
      allow(subject).to receive(:fetch_grid).and_return({})
      allow(subject).to receive(:upcloud_client).and_return(upcloud_client)
    end

    it 'raises usage error if no options are defined' do
      expect {
        subject.run([])
      }.to raise_error(Clamp::UsageError)
    end

  end
end

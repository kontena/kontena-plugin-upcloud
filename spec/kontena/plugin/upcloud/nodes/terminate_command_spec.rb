require 'spec_helper'
require 'kontena/plugin/upcloud_command'

describe Kontena::Plugin::Upcloud::Nodes::TerminateCommand do

  let(:subject) do
    described_class.new(File.basename($0))
  end

  let(:prompt) { double(:prompt) }

  describe '#run' do
    it 'raises usage error if no options are defined' do
      expect(prompt).to receive(:ask)
      expect(subject).to receive(:prompt).at_least(1).times.and_return(prompt)
      expect {
        subject.run([])
      }.to raise_error(Clamp::UsageError)
    end
  end
end

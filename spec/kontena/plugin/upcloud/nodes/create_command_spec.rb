require 'spec_helper'
require 'kontena/plugin/upcloud/nodes/create_command'

describe Kontena::Plugin::Upcloud::Nodes::CreateCommand do

  let(:subject) do
    described_class.new(File.basename($0))
  end

  let(:prompt) { double(:prompt) }

  describe '#run' do
    it 'prompts user' do
      expect(prompt).to receive(:ask)
      expect(subject).to receive(:prompt).at_least(1).times.and_return(prompt)
      expect {
        subject.run([])
      }.to raise_error(Clamp::UsageError)
    end
  end
end

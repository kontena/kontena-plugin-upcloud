module Kontena
  module Plugin
    module Upcloud
      VERSION = "0.3.0"

      ZONES = {
        'nl-ams1' => 'Amsterdam #1',
        'us-chi1' => 'Chicago #1',
        'de-fra1' => 'Frankfurt #1',
        'fi-hel1' => 'Helsinki #1',
        'uk-lon1' => 'London #1',
        'sg-sin1' => 'Singapore #1'
      }.freeze

      PLANS = {
        '1xCPU-1GB' => '1024MB / 1 CPU, 30GB MaxIOPS disk, 2048GB transfer',
        '2xCPU-2GB' => '2048MB / 2 CPU, 50GB MaxIOPS disk, 3072GB transfer',
        '4xCPU-4GB' => '40964MB / 4 CPU, 100GB MaxIOPS disk, 4096GB transfer',
        '6xCPU-8GB' => '8192MB / 6 CPU, 200GB MaxIOPS disk, 8192GB transfer'
      }.freeze
    end
  end
end

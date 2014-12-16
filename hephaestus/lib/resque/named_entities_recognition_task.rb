class NamedEntitiesRecognitionTask < BaseTask
  @queue = "named_entities_recognition_task"
  @msg = 'Named entities recognition'
  @next_task = 'store_named_entities_task'

  attr_reader :text, :metadata

  def initialize(input)
    @text = input.fetch('data', '')
    @metadata = input.fetch('metadata', {})
  end

  def call
    analyzer_client = AnalyzerClient.new(text)
    tokens = analyzer_client.tokens.to_a

    @output = {
      'data' => tokens,
      'metadata' => metadata
    }
  end
end

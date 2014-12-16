class NamedEntitiesRecognitionTask < BaseTask
  @queue = "named_entities_recognition_task"
  @msg = 'Buscando entidades'

  attr_reader :text

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

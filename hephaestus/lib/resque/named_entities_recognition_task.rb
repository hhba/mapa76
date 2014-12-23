class NamedEntitiesRecognitionTask < BaseTask
  @queue = "freeling"
  @msg = 'Buscando entidades'

  def initialize(input)
    @texts = input.fetch('data', [])
    @metadata = input.fetch('metadata', {})
  end

  def call
    token_groups = @texts.map do |text|
      analyzer_client = AnalyzerClient.new(text)
      analyzer_client.tokens.to_a
    end

    @output = {
      'data' => token_groups,
      'metadata' => metadata
    }
  end
end

class GlueTask < LoggedJob
  @queue = :glue

  class TaskFinder
    attr_reader :document

    TASKS = %w(
      NormalizationTask
      LayoutAnalysisTask
      ExtractionTask
      CoreferenceResolutionTask
    )

    def initialize(document)
      @document = document
    end
  end

  def self.perform(document_id)
    puts document_id
    sleep 5
    puts "ff"
  end
end

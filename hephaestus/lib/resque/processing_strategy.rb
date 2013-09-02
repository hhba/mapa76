module ProcessingStrategy

  class StrategySelector
    def next_step
      current_step = steps_list.find(self.class)
      current_step + 1 unless current_step == steps_list.length
    end
  end

  class Mapa76Strategy
    def step_list
      [NormalizationTask, LayoutAnalysisTask, ExtractionTask, CoreferenceResolutionTask, GeocodingTask]
    end
  end

  class AnalicemeStrategy
    def step_list
      [NormalizationTask, LayoutAnalysisTask, ExtractionTask, CoreferenceResolutionTask, GeocodingTask]
    end
  end

  def pick_strategy(strategy = :mapa76)
  end

end

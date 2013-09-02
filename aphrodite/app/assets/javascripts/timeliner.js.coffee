$ ->
  return unless $("#timeline").length

  window.timeline = new projects.Timeliner "timeline"

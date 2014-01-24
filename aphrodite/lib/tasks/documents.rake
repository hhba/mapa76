namespace :documents do
  task :process => :environment do
    Document.where(status: 'FAILED').each do |doc|
      next if doc.process_attemps > 5
      Rails.logger.info "[ReProcess] Document #{doc.title} | '#{doc.id}'"
      last_working_task = doc.status_history[-1]
      doc.status = last_working_task.to_s + '-end'
      doc.process_attemps = doc.process_attemps + 1
      doc.percentage = 0
      doc.save
      Resque.enqueue(DocumentProcessBootstrapTask, doc.id)
    end
  end
end
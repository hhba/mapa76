require "resque/tasks"
require 'ruby-progressbar'

task "resque:setup" => :environment

def process(task)
  documents = Document.all
  pbar = ProgressBar.create(:title => task.to_s, :total => documents.count)

  documents.each do |document|
    task.perform(document.id)
    pbar.increment
  end
end

namespace :process do
  desc 'Run extraction task for all the documents available'
  task extraction: :environment do
    process(ExtractionTask)
  end

  desc 'Run coreference task for all the documents available'
  task coreference: :environment do
    process(CoreferenceTask)
  end

  desc 'Run mentions task for all documents available'
  task mentions: :environment do
    process(MentionsFinderTask)
  end

  desc 'Run all tasks for all documets'
  task all: :environment do
    Rake::Task["process:extraction"].invoke
    Rake::Task["process:coreference"].invoke
    Rake::Task["process:mentions"].invoke
  end
end

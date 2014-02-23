require "resque/tasks"
require 'ruby-progressbar'
require 'active_support/all'

task "resque:setup" => :environment

def process(task)
  pbar = ProgressBar.create(:title => task.to_s, :total => Document.count)

  Document.batch_size(20).no_timeout.each do |document|
    task.perform(document.id)
    pbar.increment
    document.update_attribute :status, task.to_s.underscore + '-end'
  end
end

namespace :process do
  desc 'Run extraction task for all the documents available'
  task extraction: :environment do
    process(EntitiesExtractionTask)
  end

  desc 'Run coreference task for all the documents available'
  task coreference: :environment do
    process(CoreferenceResolutionTask)
  end

  desc 'Run mentions task for all documents available'
  task mentions: :environment do
    process(MentionsFinderTask)
  end

  desc 'Run indexer task for all documents available'
  task indexer: :environment do
    IndexerTask.create_index force: true
    process(IndexerTask)
  end

  desc 'Run all tasks for all documets'
  task all: :environment do
    Rake::Task["process:extraction"].invoke
    Rake::Task["process:coreference"].invoke
    Rake::Task["process:mentions"].invoke
    Rake::Task["process:indexer"].invoke
  end
end

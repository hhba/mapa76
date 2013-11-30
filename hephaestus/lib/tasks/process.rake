require "resque/tasks"
require 'ruby-progressbar'

task "resque:setup" => :environment

namespace :process do
  desc 'Run extraction task for all the documents available'
  task extraction: :environment do
    documents = Document.all
    pbar = ProgressBar.create(:title => "Extraction Task", :total => documents.count)

    documents.each do |document|
      ExtractionTask.perform(document.id)
      pbar.increment
    end
  end

  desc 'Run coreference task for all the documents available'
  task coreference: :environment do
    documents = Document.all
    pbar = ProgressBar.create(:title => "Coreference Task", :total => documents.count)

    documents.each do |document|
      CoreferenceTask.perform(document.id)
      pbar.increment
    end
  end

  desc 'Run mentions task for all documents available'
  task mentions: :environment do
    documents = Document.all
    pbar = ProgressBar.create(:title => "Coreference Task", :total => documents.count)

    documents.each do |document|
      MentionsFinderTask.perform(document.id)
      pbar.increment
    end
  end

  desc 'Run all tasks for all documets'
  task all: :environment do
    Rake::Task["process:extraction"].invoke
    Rake::Task["process:coreference"].invoke
    Rake::Task["process:mentions"].invoke
  end
end

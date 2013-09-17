namespace :index do
  desc 'Drop indexes'
  task :drop => :environment do
    Document.tire.index.delete
    Document.tire.import
  end
end

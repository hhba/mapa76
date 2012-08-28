require 'csv'

namespace :convicted do
  desc 'Load CSV with the list of processed and convicted repressors'
  task :load do
    CSV_PATH = ENV['CSV_PATH'] || File.join(Padrino.root, 'data')

    def clean_name(name)
      if name.include? ","
        name = name.split(",")
        name[1].strip + " " + name[0].capitalize
      else
        name.capitalize
      end
    end

    def searchable_name(name)
      clean_name(name).downcase
    end

    %w(condenados1 condenados2 procesados).each do |filename|
      convicted = CSV.open(File.join(CSV_PATH, filename + '.csv'))
      convicted.shift
      convicted.each do |row|
        unless row[6].nil?
          puts "Convicted: #{clean_name row[5]} from #{filename}"
          Person.add clean_name(row[5]),
                     confidence: 1,
                     tag: filename,
                     force: row[6],
                     jurisdiction: row[0]
        end
      end
    end
  end
end


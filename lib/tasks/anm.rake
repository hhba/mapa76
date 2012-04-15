namespace :anm do
  desc 'Load JSON files from ANM scrapped documents'
  task :load do
    JSON_PATH = ENV['JSON_PATH'] || File.join(Padrino.root, 'data', 'anm')

    Dir[File.join(JSON_PATH, '*.json')].each do |filename|
      MultiJson.decode(open(filename), :symbolize_keys => true).each do |person|
        attrs = person.slice(:surname_father, :surname_mother, :names, :nicknames)
        attrs[:name] = attrs.delete(:names)

        [:name, :surname_father, :surname_mother, :name].each do |key|
          attrs[key] = attrs[key].titleize if attrs[key]
        end
        attrs[:nicknames].map! { |name| name.titleize } if attrs[:nicknames]
        attrs[:confidence] = 1.0

        Person.create(attrs)
      end
    end
  end
end

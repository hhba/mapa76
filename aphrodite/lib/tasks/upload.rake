desc 'Upload documents'
task upload: :environment do
  user = User.where(email: 'esma@gmail.com').first
  user.destroy if user
  user = User.new(email: 'esma@gmail.com')
  user.password = 'password'
  user.save

  Dir.glob(Rails.root + 'tmp/txt/*.txt').sort.each do |file|
    document = Document.new original_filename: file.split('/')[-1]
    document.file = file
    user.documents << document
    if document.save
      Rails.logger.info("** AUTOUPLOAD: #{file} was successful")
    else
      Rails.logger.fatal("** AUTOUPLOAD: #{file} failed!")
    end
  end
end

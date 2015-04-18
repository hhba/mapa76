require 'azure'

git_describe = `git describe`
release_hash = git_describe.split('-')[-1].strip

Azure.config.storage_account_name = ENV['AZURE_STORAGE_ACCOUNT']
Azure.config.storage_access_key = ENV['AZURE_STORAGE_ACCESS_KEY']

azure_blob_service = Azure::BlobService.new

Dir['../aeolus/dist/**/*'].reject {|fn| File.directory?(fn) }.each do |file|
  blob = "#{release_hash}/#{file.split('/')[3..-1].join('/')}"
  puts "Uploading #{blob}"
  azure_blob_service.create_block_blob(
    'aeolus', # Container name
    blob,
    File.open(file, "rb") { |f| f.read }
  )
end

Dir['../aeolus/dist/**/*'].reject {|fn| File.directory?(fn) }.each do |file|
  blob = "latest/#{file.split('/')[3..-1].join('/')}"
  puts "Uploading #{blob}"
  azure_blob_service.create_block_blob(
    'aeolus', # Container name
    blob,
    File.open(file, "rb") { |f| f.read }
  )
end

puts "Your base domain is http://az745887.vo.msecnd.net/aeolus/#{release_hash}"
puts "Your base domain is http://az745887.vo.msecnd.net/aeolus/latest"
puts "Release hash: #{release_hash}"

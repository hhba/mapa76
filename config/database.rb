MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)

case Padrino.env
  when :development then MongoMapper.database = 'alegato_development'
  when :production  then MongoMapper.database = 'alegato_production'
  when :test        then MongoMapper.database = 'alegato_test'
end

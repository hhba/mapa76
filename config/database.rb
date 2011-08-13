Sequel::Model.plugin(:schema)
Sequel::Model.raise_on_save_failure = false # Do not throw exceptions on failure
Sequel::Model.db = Sequel.connect(CONFIG['dsn'], :loggers => [logger])
Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :timestamps

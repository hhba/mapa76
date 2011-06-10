class Milestone
  include MongoMapper::EmbeddedDocument
  key :date_from, Date
  key :date_to, Date
  key :what, String
  key :where, String
  key :type, String
  key :source, String
end

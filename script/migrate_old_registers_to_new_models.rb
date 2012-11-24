#!/usr/bin/env ruby
##
# Migrate a JSON dump of old `registers` collection to the new collections for
# storing registers of facts and relations.  You need a dump of `registers`:
#
# mongoexport --db mapa76 --collection registers --out registers.json
#
# NOTE Please, backup your data before running this.
#

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), ".."))
require "config/boot"

if ARGV.size != 1
  puts "Usage: #{$0} JSON_DUMP"
  exit(1)
end

json_file = ARGV.first
if not File.exists?(json_file)
  puts "#{json_file} does not exist"
  exit(2)
end

puts "=> Rename `named_entities` collection to `citations` (base class of NEs)"
Mongoid.master[:named_entities].rename(:citations)

puts "=> Create registers, facts and relations from JSON dump"
File.open(json_file).each do |line|
  data = MultiJson.decode(line)
  data.symbolize_keys!

  puts "  > add register #{data[:_id]}"

  document_id = data[:document_id].values.first

  # TODO Search for the nearest ActionEntity of the "person" named entity
  action = ActionEntity.find_or_create_by({
    document_id: document_id,
    lemma: data[:what].strip.downcase,
  })

  # Create "subject" fact
  subject_fact = Fact.create!
  # Create "subject" fact register
  subject_fr = FactRegister.create!({
    document_id: document_id,
    person_ids: data[:who],
    place_id: data[:where].first,
    date_id: data[:when].first,
    action_ids: [action.id],
    passive: false,
  })
  subject_fact.registers << subject_fr

  if not data[:to_who].empty?
    # Create "complement" fact
    complement_fact = Fact.create!
    # Create "complement" fact register
    complement_fr = FactRegister.create!({
      document_id: document_id,
      person_ids: data[:to_who],
      place_id: data[:where].first,
      date_id: data[:when].first,
      action_ids: [action.id],
      passive: true,
    })
    complement_fact.registers << complement_fr

    # Create relation
    relation = Relation.create!
    # Create relation register using recently created
    # "subject" and "complement" fact registers.
    relation_register = RelationRegister.create!({
      document_id: document_id,
      subject_register_id: subject_fr.id,
      complement_register_id: complement_fr.id,
    })
    relation.registers << relation_register
  end
end

puts "=> Delete now unused `registers` collection"
Mongoid.master[:registers].drop

puts "=> Done"

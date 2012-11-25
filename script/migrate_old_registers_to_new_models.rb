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

puts "=> Delete now unused `registers` collection"
Mongoid.master[:registers].drop

puts "=> Create registers, facts and relations from JSON dump"
File.open(json_file).each do |line|
  data = MultiJson.decode(line)
  data.symbolize_keys!

  puts "  > add register #{data[:_id]}"

  document_id = data[:document_id].values.first

  # TODO Search for the nearest ActionEntity of the "person" named entity
  action = ActionEntity.find_or_create_by({
    document_id: document_id,
    lemma: data[:what].strip.downcase
  })

  # Create fact and its register
  fact = Fact.create!
  fr = FactRegister.new({
    document_id: document_id,
    place_id: data[:where].first,
    date_id: data[:when].first,
    action_ids: [action.id],
  })

  # If "who" was not provided but "to_who", voice is passive
  if data[:who].blank? && !data[:to_who].blank?
    fr.person_ids = data[:to_who]
    fr.passive = true
  else
    fr.person_ids = data[:who]
    fr.complement_person_ids = data[:to_who]
    fr.passive = false
  end
  fr.save!

  fact.registers << fr
end

puts "=> Done"

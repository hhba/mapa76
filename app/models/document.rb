#encoding: utf-8
require "text"
class Document < Sequel::Model
  many_to_many :person
  one_to_many :milestones
  attr_accessor :sample_mode
  def path
      File.join(File.expand_path(File.dirname(__FILE__)),"../../","data","#{id}.txt")
  end
  def data=(data)
    save if new?
    open(path,'w'){|fd| fd.write(data)}
  end
  def fd
    return @fd if @fd
    @fd = open(path,"r:UTF-8")
    @fd.set_encoding("UTF-8")
    @fd
  end
  def read(*p)
    if p.empty? and @sample_mode
      p = [100 * 1024]
    end
    r=fd.read(*p)
    r.force_encoding("UTF-8")
    r
  end
  def fragment(start_pos,end_pos)
    fd.seek(start_pos)
    orig = self.read(end_pos - start_pos)
    orig.force_encoding("UTF-8")
    #fix UTF-8
    r=orig.tidy_bytes
    Text::StringWithContext.new_with_context(r,"",start_pos,start_pos + r.bytesize,self) 
  end
  def extract
    @process_text ||= Text.new(self)
  end
  def method_missing(p,args=[])
    fd.send(p,*args)
  end
  def add_person(person,mentions=1)
    r = false
    if person_dataset.filter(:person_id => person.id).empty?
      r=super(person)
    end
    doc_id = self.id
    person_id = person.id
    DocumentsPerson.filter(:document_id => doc_id, :person_id => person_id).set(:mentions => :mentions + mentions)
    r
  end
end
Document.plugin :json_serializer

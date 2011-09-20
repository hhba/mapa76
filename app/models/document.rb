#encoding: utf-8
require "text"

class Document
  include Mongoid::Document
  include Mongoid::Timestamps

  def _dump(level)
    id.to_s
  end
  def self._load(arg)
    self[arg]
  end  


  field :title, type: String
  field :content, type: String

  has_many :milestones
  has_and_belongs_to_many :people

  attr_accessor :sample_mode

  def path
    File.join(File.expand_path(File.dirname(__FILE__)),"../../","data","#{id}.txt")
  end
  def length
    fd{|fd| fd.read.size}
  end

  def data=(data)
    save if new?
    open(path,'w'){|fd| fd.write(data)}
  end
  def fd(&block)
    open(path,"r:UTF-8"){|fd|
      fd.set_encoding("UTF-8")
      yield(fd)
    }
  end

  def read(*p)
    if p.empty?
      @___text ||= fd{|fd| fd.read}
    else
      fd{|fd| fd.read(*p)}
    end
  end

  def fragment(start_pos,end_pos)
    text = read()
    fragment = text[start_pos ... end_pos]
    Text::StringWithContext.new_with_context(fragment,text,start_pos,end_pos,self)
  end

  def extract
    @process_text ||= Text.new(self)
  end

end
# Document.plugin :json_serializer


#encoding: utf-8
class String
  def tidy_bytes
    self.chars.select{|c| c.valid_encoding?}.join
  end
end
require File.expand_path(File.dirname(__FILE__))+"/procesar_texto.rb"
class Document
  attr_reader :id
  attr_accessor :sample_mode, :title
  def self.find_by_id(id)
     id = id.to_i
     docs=[ ]
     docs[1] = {:path => "alegato2.txt", :title => "Alegato del fiscal - Banco, Atlético, Olimpo"}
     self.new(File.join(File.expand_path(File.dirname(__FILE__)),"..","data",docs[id][:path]),docs[id][:title],id)
  end
  def initialize(path,title,id=nil)
    @path=path
    @title = title
    @id=id
  end
  def fd
    return @fd if @fd
    @fd = open(@path,"r:UTF-8")
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
    ProcesarTexto::StringWithContext.new_with_context(r,"",start_pos,start_pos + r.bytesize,self) 
  end
  def extract
    @process_text ||= ProcesarTexto.new(self)
  end
  def method_missing(p,args=[])
    fd.send(p,*args)
  end
end

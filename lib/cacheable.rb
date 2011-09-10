module Cacheable
  require "digest/md5" 
  CACHE_DIR='/tmp/cache_procesar_texto/'
  require "fileutils"
  File.exists?(CACHE_DIR) || FileUtils.mkdir_p(CACHE_DIR)
  require 'yaml'
  def cache_debug(&block)
    STDERR.write("#{Time.now} #{yield}\n") if ENV['CACHE_DEBUG']
  end
  def cache_load(id)
    path = cache_dir(id)
    if not File.exists?(path)
      cache_debug{"#{id} is not cached (#{path})" }
      return :notcached 
    end
    begin
      cache_debug{"#{id} loading (#{path})" }
      r=Marshal.load(open(path).read)
      cache_debug{"#{id} loaded" }
      r
    rescue
      raise
      nil
    end
  end
  def cache_enabled
    @cache_enabled && !ENV['SKIP_CACHE'] 
  end
  def cache_enabled=(v)
    @cache_enabled=v
  end
  def cache_fetch(key)
    return yield if not cache_enabled
    id = cache_gen_id(key)
    cached=self.cache_load(id)
    if cached == :notcached
      val=yield
      cache_write(id,val)
    else
      cached
    end
  end
  def cache_gen_id(key)
    self.class.name.to_s + key.to_s 
  end
  def cache_dir(id)
    File.join(CACHE_DIR,Digest::MD5.hexdigest(id))
  end
  def cache_write(id,data)
    dir = cache_dir(id)
    begin
      open(dir,'w'){|fd|
        Marshal.dump(data,fd)
      }
    rescue
      puts "Cannot dump! #{$!}"
    end
    data
  end
  module ClassMethods
    def self.clean_cache
    end
  end
  def self.included(m)
    m.extend(ClassMethods)
  end
end


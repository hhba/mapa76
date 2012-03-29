#encoding: utf-8
require 'test/unit'
require 'cacheable'

class CachedString < String
  include Cacheable

  def initialize(*s)
    self.cache_enabled = true
    super
  end

  def randomize
    cache_fetch("randomstr") do
      Time.now.to_f.to_s
    end
  end
end

class TestCacheable < Test::Unit::TestCase
  def test_no_cache_instance
    ENV.delete("SKIP_CACHE")
    a = CachedString.new
    a.cache_enabled = true
    r1 = a.randomize
    r2 = a.randomize
    assert_equal(r1, r2, "Cached results should be equal")
    a.cache_enabled = false
    r3 = a.randomize
    assert_not_equal(r1, r3, "Non cached results should be different")
  end

  def test_no_cache_env
    ENV.delete("SKIP_CACHE")
    a = CachedString.new
    r1 = a.randomize
    r2 = a.randomize
    assert_equal(r1, r2, "Cached results should be equal")
    ENV["SKIP_CACHE"] = "true"
    r3 = a.randomize
    assert_not_equal(r1, r3, "Non cached results should be different")
    ENV.delete("SKIP_CACHE")
  end
end

#!/usr/bin/env ruby
if ARGV.length == 0
  STDERR.write("#{$0} doc\n")
  exit
end
require File.expand_path(File.dirname(__FILE__)) + "/../config/boot.rb"

ARGV.each{|fn|
  if not fn.end_with?(".txt")
    STDERR.write("Only txt files are supported (#{fn})\n")
    next
  end
  doc = Document.new
  doc.title = File.basename(fn, File.extname(fn))
  doc.data = open(fn).read
  if not doc.save
    STDERR.write("Error saving #{fn}!\n")
  end
}


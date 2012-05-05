require 'stemmer'
require 'madeleine'
require 'classifier'
require 'singleton'

class String
  # http://blog.monoweb.info/article/2010091116.html
  alias_method :original_stem, :stem

  def stem
    self.original_stem.force_encoding(self.encoding)
  end
end

module Classifiable
  class Classifiers < Hash
    include Singleton
  end

  module ClassMethods
    def classifier
      return Classifiers.instance[self.name] if Classifiers.instance[self.name]
      path = File.join(File.expand_path(File.dirname(__FILE__) + "/../data/"), self.name)
      Classifiers.instance[self.name] = SnapshotMadeleine.new(path) do
        Classifier::Bayes.new 'good', 'bad'
      end
    end

    def train(good_or_bad, str)
      classifier.system.send("train_#{good_or_bad}".to_sym, str)
    end

    def training_save
      classifier.take_snapshot
    end

    def classify(str)
      classifier.system.classify(str).downcase
    end
  end

  def classify
    self.class.classify(self.to_s)
  end

  def classified_good?
    classify == "good"
  end

  def self.included(m)
    m.extend(ClassMethods)
  end
end


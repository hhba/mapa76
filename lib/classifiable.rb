module Classifiable
  class Classifiers < Hash
    require "singleton"
    include Singleton
  end
  module ClassMethods
    require 'madeleine'
    require "stemmer"
    def classifier
      puts File.dirname(__FILE__) + "/../data/#{self.name}"
      return Classifiers.instance[self.name] if Classifiers.instance[self.name]
      path=File.join(File.expand_path(File.dirname(__FILE__) + "/../data/"), self.name)
      Classifiers.instance[self.name] = SnapshotMadeleine.new(path) {
        Classifier::Bayes.new 'good', 'bad'
      }
    end
    def train(good_or_bad,str)
      classifier.system.send("train_#{good_or_bad}".to_sym,str)
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
  def self.included(m)
    m.extend(ClassMethods)
  end
end


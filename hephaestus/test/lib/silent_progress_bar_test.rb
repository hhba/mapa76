require 'test_helper'

describe SilentProgressBar do
  describe '#new' do
    it 'can initialize with a hash' do
      progress_bar = SilentProgressBar.new '', 1000, starting_at: 25,
        ending_at: 50
      progress_bar.current.must_equal 25
      progress_bar.starting_at.must_equal 25
      progress_bar.ending_at.must_equal 50
    end
  end

  context 'normal conditions' do
    describe '#increment and #progress' do
      it 'increments %' do
        progress_bar = SilentProgressBar.new ''
        progress_bar.increment
        progress_bar.progress.must_equal 1
        progress_bar.increment
        progress_bar.progress.must_equal 2
      end
    end

    describe '#progress=' do
      it 'changes progress' do
        progress_bar = SilentProgressBar.new ''
        progress_bar.progress = 10
        progress_bar.progress.must_equal 10
      end
    end
  end

  describe '#starting_at=' do
    it 'changes the starting point' do
      progress_bar = SilentProgressBar.new ''
      progress_bar.starting_at = 10
      progress_bar.progress = 10
      progress_bar.increment
      progress_bar.progress = 11
    end
  end

  describe '#ending_at' do
    it 'never pass ending_at point' do
      progress_bar = SilentProgressBar.new ''
      progress_bar.ending_at = 60
      progress_bar.bound = 3
      progress_bar.increment
      progress_bar.increment
      progress_bar.increment
      progress_bar.increment
      progress_bar.progress.must_equal 60
    end
  end

  context "change unit's scale" do
    describe '#bound=' do
      it 'changes the bound' do
        progress_bar = SilentProgressBar.new ''
        progress_bar.bound = 10
        progress_bar.progress.must_equal 0
        progress_bar.increment
        progress_bar.progress.must_equal 10
      end

      it 'changes scale and bound' do
        progress_bar = SilentProgressBar.new ''
        progress_bar.bound = 300
        progress_bar.starting_at = 20
        progress_bar.ending_at = 50
        progress_bar.progress.must_equal 20
        10.times { progress_bar.increment }
        progress_bar.progress.must_be_within_delta 21
      end
    end
  end
end

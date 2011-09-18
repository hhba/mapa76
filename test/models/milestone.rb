#!/usr/bin/env ruby
#encoding: utf-8
ENV["RACK_ENV"] = PADRINO_ENV = "test"
require File.expand_path(File.dirname(__FILE__)) + "/../../config/boot.rb"

require "test/unit"

class TestMilestone < Test::Unit::TestCase

  def setup
    #Person.dataset.truncate
    Person.delete_all
    #Milestone.dataset.truncate
    Milestone.delete_all
    @p1 = Person.create(name: "Cocó Fuente")
  end

  def test_start_end
    milestone = Milestone.new
    milestone.date_from = Date.today - 10
    milestone.date_to = Date.today
    milestone.where = "Aca"
    milestone.what = "Eso"
    #@p1.add_milestone(milestone)
    @p1.milestones << milestone

    assert_equal([milestone],@p1.milestones)
  end

  def test_partial_start_end
    m1 = Milestone.new
    m1.date_from = IncompleteDate.new(2007,10)
    m1.date_to = Date.today
    m1.where = "Aca"
    m1.what = "Eso"
    m1.save

    #milestone = Milestone[m1.id]
    milestone = Milestone.find(m1.id)
    assert_equal(IncompleteDate.new(2007,10),milestone.date_from_range)
    assert_equal(IncompleteDate.new(Date.today),milestone.date_to_range)
  end

  def test_partial_start_no_end
    m1 = Milestone.new
    m1.date_from = IncompleteDate.new(2007,10)
    m1.date_to = nil
    m1.where = "Aca"
    m1.what = "Eso"
    m1.save

    #milestone = Milestone[m1.id]
    milestone = Milestone.find(m1.id)
    assert_equal(IncompleteDate.new(2007,10),milestone.date_from_range)
    assert_equal(nil,milestone.date_to_range)
  end

end

class TestMilestoneWhatWhereLists < Test::Unit::TestCase

  def setup
    #Person.dataset.truncate
    Person.delete_all
    #Milestone.dataset.truncate
    Milestone.delete_all
    @p1=Person.create(name: "Cocó Fuente")
    milestone = Milestone.new
    milestone.date_from = Date.today - 10
    milestone.date_to = Date.today
    milestone.where = "Aca"
    milestone.what = "Eso"
    #@p1.add_milestone(milestone)
    @p1.milestones << milestone

    milestone = Milestone.new
    milestone.date_from = Date.today - 11
    milestone.date_to = Date.today
    milestone.where = "Alla"
    milestone.what = "Aquello"
    #@p1.add_milestone(milestone)
    @p1.milestones << milestone

    milestone = Milestone.new
    milestone.date_from = Date.today - 110
    milestone.date_to = Date.today
    milestone.where = "Alla"
    milestone.what = "Aquello"
    #@p1.add_milestone(milestone)
    @p1.milestones << milestone
  end

  def test_what_lists
    assert_equal(["Aquello","Eso"].sort,Milestone.what_list.sort)
  end

  def test_where_lists
    assert_equal(["Aca","Alla"],Milestone.where_list)
  end

end


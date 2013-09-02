require "test_helper"

class DocumentsHelperText < ActiveSupport::TestCase
  class MockView < ActionView::Base
    include DocumentsHelper
  end

  setup do
    @template = MockView.new
    @document = create :document
  end

  context "#status" do
    should "return a Hash with the status of the document" do
      @document.update_attributes :percentage => 100, :category => "Veredicto"

      status = @template.status(@document)

      assert_equal @document.id, status[:id]
      assert_equal @document.title, status[:title]
      assert_equal @document.category, status[:category]
      assert_equal @document.percentage, status[:percentage]
      assert_equal @document.readable?, status[:readable]
      assert_equal @document.geocoded?, status[:geocoded]
      assert_equal @document.exportable?, status[:exportable]
      assert_equal @document.completed?, status[:completed]
      assert_equal @document.id.generation_time.strftime("%d/%m/%y"), status[:generation_time]
      assert_equal @template.thumbnail_url(@document), status[:thumbnail]
    end
  end
end

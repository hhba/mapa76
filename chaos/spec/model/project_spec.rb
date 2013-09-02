require "spec_helper"

describe Project do
  before do
    @project = FactoryGirl.create :project
    @document_1 = FactoryGirl.create :document
    @document_2 = FactoryGirl.create :document

    @project.documents << @document_2
  end

  it "should add a new document to a project" do
    @project.add_document_by_id @document_1.id
    assert_equal @project.documents, [@document_2, @document_1]
  end

  it "should remove an existing document" do
    @project.remove_document_by_id @document_2.id
    assert_equal @project.documents.length, 0
  end
end

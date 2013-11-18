class Api::V2::PeopleController < Api::V2::BaseController
  def index
    if params[:document_id]
      document = current_user.documents.find(params[:document_id])
      @people = document.people
    else
      @people = document_ids.map do |id|
        current_user.documents.find(id).people
      end.flatten
    end
  end

  def show
    @person = Person.find(params[:id])
  end
end

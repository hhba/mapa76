class Api::V1::PeopleController < Api::V1::BaseController
  before_filter :authenticate_user!

  def show
    person = current_user.people.find(params[:id])
    respond_with({
      name: person.name,
      mentions: person.mentions,
      id: person.id,
    })
  end
end

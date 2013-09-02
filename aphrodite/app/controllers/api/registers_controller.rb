class Api::RegistersController < ApplicationController
  def create
    register = nil

    begin
      action = ActionEntity.find_or_create_by({
        document_id: params[:document_id],
        lemma: params[:what].strip.downcase
      })

      # Create fact and its register
      fact = Fact.create!
      fr = FactRegister.new({
        document_id: params[:document_id],
        place_id: params[:where].first,
        date_id: params[:when].first,
        action_ids: [action.id],
      })

      # If "who" was not provided but "to_who", voice is passive
      if params[:who].blank? && !params[:to_who].blank?
        fr.person_ids = params[:to_who]
        fr.passive = true
      else
        fr.person_ids = params[:who]
        fr.complement_person_ids = params[:to_who]
        fr.passive = false
      end
      fr.save!

      fact.registers << fr
    rescue
      response.status = 405
      render :nothing => true
    else
      response.status = 201
      # FIXME check if response is handled OK on the client-side JS
      render :json => register
    end
  end
end

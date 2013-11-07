class Api::V1::DocumentsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def index
    respond_with Document.where(user_id: current_user.id).order_by(order)
  end

  def update
    document = current_user.documents.find(params[:id])
    document.update_attributes params[:document]
    respond_with document
  end

private

  def order
    "#{sort_column} #{sort_direction}"
  end

  def sort_column
    %w[created_at title].include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end

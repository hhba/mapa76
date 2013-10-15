# encoding: utf-8

class InvitationsController < ApplicationController
  before_filter :only_signed_off

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new params[:invitation]
    NotificationMailer.invitation_request(@invitation).deliver
    if @invitation.save
      redirect_to root_path, notice: 'Se ha creado el pedido de invitación'
    else
      render :new, error: 'No se ha podido cargar el pedido de invitación'
    end
  end
end

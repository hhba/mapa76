# encoding: utf-8

class InvitationsController < ApplicationController
  layout 'pretty'
  before_filter :only_signed_off

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new params[:invitation]
    @invitation.save
    NotificationMailer.invitation_request(@invitation).deliver
    redirect_to root_path, notice: 'Se ha creado el pedido de invitación'
  end
end

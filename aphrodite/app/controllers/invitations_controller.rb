# encoding: utf-8

class InvitationsController < ApplicationController
  before_filter :only_signed_off

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new params[:invitation]
    @invitation.save
    NotificationMailer.invitation_request(@invitation).deliver
    redirect_to root_path, notice: 'Ud. ha pedido una invitación para Analice.me. Le responderemos a la brevedad.'
  end
end

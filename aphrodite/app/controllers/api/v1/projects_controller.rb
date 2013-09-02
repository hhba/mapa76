module Api
  module V1
    class ProjectsController < ApplicationController
      before_filter :authenticate_user!, only: [:index]

      def show
        @project = Project.find params[:id]
      end

      def timeline
        @project = Project.find params[:id]
      end

      def index
        @projects = current_user.projects
      end
    end
  end
end

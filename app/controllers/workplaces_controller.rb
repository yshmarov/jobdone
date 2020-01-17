class WorkplacesController < ApplicationController
  def show
    @workplace = Workplace.friendly.find(params[:id])
    @members = Member.active.order('created_at ASC')
    @locations = Location.all.includes(:workplaces)
    @jobs = @workplace.jobs.includes(:service, :member, :event => [:client])
    render 'dashboard/calendar'
  end

  def destroy
    @workplace = Workplace.friendly.find(params[:id])
    @workplace.destroy
    if @workplace.errors.present?
      redirect_to locations_url, alert: 'Workplace has associated records. Can not delete.'
    else
      redirect_to locations_url, notice: 'Workplace was successfully destroyed.'
    end
  end
end
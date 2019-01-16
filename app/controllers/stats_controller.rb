class StatsController < ApplicationController
  def finances
    if current_user.has_role?(:admin)
      #company confirmed earning
      @confirmed_hours_worked = (Job.joins(:appointment).where(appointments: {status: ['confirmed']}).map(&:service_duration).sum)/60.to_d
      @confirmed_job_q = Job.joins(:appointment).where(appointments: {status: ['confirmed']}).count
      @total_confirmed_earnings = Job.joins(:appointment).where(appointments: {status: ['confirmed']}).map(&:client_due_price_cents).sum
      @total_confirmed_expences = Job.joins(:appointment).where(appointments: {status: ['confirmed']}).map(&:member_due_price_cents).sum
      @total_confirmed_net_income = @total_confirmed_earnings - @total_confirmed_expences
  
      #company planned earnings
      @planned_hours_worked = (Job.joins(:appointment).where(appointments: {status: 'planned'}).map(&:service_duration).sum)/60.to_d
      @planned_job_q = Job.joins(:appointment).where(appointments: {status: 'planned'}).count
      @total_planned_earnings = Job.joins(:appointment).where(appointments: {status: 'planned'}).map(&:client_price_cents).sum
      @total_planned_expences = Job.joins(:appointment).where(appointments: {status: 'planned'}).map(&:member_price_cents).sum
      @total_planned_net_income = @total_planned_earnings - @total_planned_expences
  
      #company loss stats
      @lost_hours_worked = (Job.joins(:appointment).where(appointments: {status: ['client_cancelled', 'member_cancelled', 'client_not_attended']}).map(&:service_duration).sum)/60.to_d
      @lost_job_q = Job.joins(:appointment).where(appointments: {status: ['client_cancelled', 'member_cancelled', 'client_not_attended']}).count
      @total_lost_earnings = Job.joins(:appointment).where(appointments: {status: ['client_cancelled', 'member_cancelled', 'client_not_attended']}).map(&:client_price_cents).sum
      @total_lost_expences = Job.joins(:appointment).where(appointments: {status: ['client_cancelled', 'member_cancelled', 'client_not_attended']}).map(&:member_price_cents).sum
      @total_net_losses = @total_lost_earnings - @total_lost_expences
  
      #average paycheck
      @average_confirmed_earnings = Job.joins(:appointment).where(appointments: {status: ['confirmed']}).average(:client_due_price).to_i/100
    else
      redirect_to root_path, alert: 'You are not authorized to view the page.'
    end
  end

  def clients
    if current_user.has_role?(:admin)
      #pie charts
      @client_gender_pie = Client.unscoped.group("gender").count
      @client_status_pie = Client.unscoped.group("status").count
      #next 5 bdays
      next_bdays = (Date.today + 0.day).yday
      @clients = Client.where("EXTRACT(DOY FROM date_of_birth) >= ?", next_bdays).order('EXTRACT (DOY FROM date_of_birth) ASC').first(5)
    else
      redirect_to root_path, alert: 'You are not authorized to view the page.'
    end
  end

  def members
    if current_user.has_role?(:admin)
      #performance vs others
      @members = Member.all
    else
      redirect_to root_path, alert: 'You are not authorized to view the page.'
    end
  end

  def appointments
    if current_user.has_role?(:admin)
      #pie charts
      @appointment_status_pie = Appointment.unscoped.group("status").count
      #appointment Q per month (only confirmed)
      @monthly_appointments = Appointment.joins(:appointment).where(appointments: {status: ['confirmed']}).map { |appointment| [Date::MONTHNAMES[appointment.starts_at.month], appointment.starts_at.year].join(' ') }.each_with_object(Hash.new(0)) { |month_year, counts| counts[month_year] += 1 }
    else
      redirect_to root_path, alert: 'You are not authorized to view the page.'
    end
  end

  def services
    if current_user.has_role?(:admin)
      #highest Q
      #highest earnings
      @services = Service.all
    else
      redirect_to root_path, alert: 'You are not authorized to view the page.'
    end
  end

  def locations
    if current_user.has_role?(:admin)
      @locations = Location.all
    else
      redirect_to root_path, alert: 'You are not authorized to view the page.'
    end
  end

end

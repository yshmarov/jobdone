class AfterSignupWizardController < ApplicationController
  include Wicked::Wizard
  before_action :set_progress, only: [:show, :update]

  steps :tenant_settings, :profile_settings

  def show
    authorize User, :edit?
    case step
    when :tenant_settings
      @favicon = 'Settings'
      @tenant = Tenant.find(Tenant.current_tenant_id)
    when :profile_settings
      @favicon = 'User'
      @member = current_user.member
    end
    render_wizard
  end

  def update
    authorize User, :edit?
    case step
    when :tenant_settings
      @favicon = 'Settings'
      @tenant = Tenant.find(Tenant.current_tenant_id)
      @tenant.update(tenant_params)
      render_wizard @tenant
    when :profile_settings
      @favicon = 'User'
      @member = current_user.member
      @member.update_attributes(member_params)
      render_wizard @member
    end
  end

  def finish_wizard_path
    start_path
    #calendar_member_path(current_user.member)
  end
  
  private
    def set_progress
      @progress = ((wizard_steps.index(step) + 1).to_d / wizard_steps.count.to_d) * 100
    end

    def tenant_params
      params.require(:tenant).permit(:name, :default_currency, :locale, :time_zone,
                      :industry, :logo, :website, :online_booking, :description, :instagram)
    end

    def member_params
      params.require(:member).permit(:first_name, :last_name, :phone_number, :email, :time_zone, :online_booking)
    end
end

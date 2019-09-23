class StaticPagesController < ApplicationController
  skip_before_action :authenticate_tenant!, :only => [ :landing_page, :features, :pricing, :privacy_policy, :terms_of_service, :security, :stats, :apply ]

  def landing_page
    if current_user
      redirect_to calendar_path
    end
  end
  
  def apply
    if current_user
      redirect_to calendar_path
    end
  end
  
  def features
    if current_user
      redirect_to calendar_path
    end
  end
  
  def pricing
    if current_user
      redirect_to calendar_path
    end
  end

  def privacy_policy
    if current_user
      redirect_to calendar_path
    end
  end
  
  def terms_of_service
    if current_user
      redirect_to calendar_path
    end
  end
  
  def security
    if current_user
      redirect_to calendar_path
    end
  end

  before_action :authenticate, only: :stats
  
  def stats
    if current_user
      redirect_to calendar_path
    end
    @ransack_tenants = Tenant.all.unscoped.search(params[:tenants_search], search_key: :tenants_search)
    @tenants = @ransack_tenants.result.paginate(:page => params[:page], :per_page => 50).order("created_at DESC")
  end

  protected
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "passa" && password == "usera"
    end
  end
end
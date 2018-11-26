class ServicesController < ApplicationController
  before_action :set_service, only: [:show, :edit, :update, :destroy]

  def index
    #@services = Service.all
    @q = Service.ransack(params[:q])
    @services = @q.result.includes(:service_category).paginate(:page => params[:page], :per_page => 10).order("created_at DESC")
  end

  def show
    authorize @service
  end

  def new
    authorize @service
    @service = Service.new
  end

  def edit
    authorize @service
  end

  def create
    authorize @service
    @service = Service.new(service_params)

    respond_to do |format|
      if @service.save
        format.html { redirect_to @service, notice: 'Service was successfully created.' }
        format.json { render :show, status: :created, location: @service }
      else
        format.html { render :new }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @service
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to @service, notice: 'Service was successfully updated.' }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @service
    @service.destroy
    respond_to do |format|
      format.html { redirect_to services_url, notice: 'Service was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_service
      @service = Service.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:name, :description, :duration, :client_price_cents, :employee_percent, :employee_price_cents, :quantity, :status, :service_category_id, :client_price, :employee_price)
    end
end

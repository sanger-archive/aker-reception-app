class Manifests::PrintController < ApplicationController
  include ManifestCounts

  before_action :check_ssr_membership, :manifests, :printers, :show_printed?
  before_action :printer, only: [:create]

  # GET /manifests/print
  def index
    respond_to do |format|
      format.html
      format.js { render template: "manifests/print/_form" }
    end
  end

  # POST /manifests/print
  def create
    if params[:manifest_ids].blank?
      flash.now[:alert] = "You must select at least one Manifest to print."
    elsif print_manifests
      redirect_to manifests_dispatch_index_path, notice: success_notice and return
    else
      flash.now[:alert] = failure_alert
    end
    render :index
  end

private

  def manifests
    manifests = Manifest.includes(:labware_type)
    @manifests = show_printed? ? manifests.printed : manifests.active
  end

  def show_printed?
    @show_printed ||= params[:status] == "printed"
  end
  helper_method :show_printed?

  def printers
    @printers ||= Printer.all
  end

  def print_manifests
    if printer.print_manifests(selected_manifests)
      return update_manifests_and_labware_count!
    end
    return false
  end

  def printer
    @printer ||= Printer.find_by(name: params[:printer][:name])
  end

  def selected_manifests
    Manifest.where(id: params[:manifest_ids])
  end

  def update_manifests_and_labware_count!
    begin
      ActiveRecord::Base.transaction do
        active_manifests.each do |manifest|
          manifest.update_attributes!(status: Manifest.PRINTED)
          manifest.labwares.each { |lw| lw.increment_print_count! }
        end
      end
      return true
    rescue
      return false
    end
  end

  def active_manifests
    selected_manifests.where(status: "active")
  end

  def success_notice
    "Labels for labware from #{'Manifest'.pluralize(selected_manifests.count)} " \
    "#{manifest_ids.join(", ")} sent to #{printer.name}."
  end

  def manifest_ids
    selected_manifests.map(&:id)
  end

  def failure_alert
    "There was an error printing your labels. Please try again, or contact an administrator."
  end

end

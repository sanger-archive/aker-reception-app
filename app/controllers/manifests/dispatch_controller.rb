class Manifests::DispatchController < ApplicationController
  include ManifestCounts

  before_action :check_ssr_membership, :manifests

  def index
    respond_to do |format|
      format.html
      format.js { render template: "manifests/dispatch/_form" }
    end
  end

  def create
    if params[:manifest_ids].blank?
      flash.now[:alert] = "You must select at least one Manifest to dispatch."
    elsif dispatch_manifests
      flash.now[:success] = success_message
    else
      flash.now[:alert] = "Manifests could not be dispatched."
    end
    render :index
  end

private

  def manifests
    @manifests ||= if show_dispatched?
        Manifest.includes(:labware_type).dispatched.order(dispatch_date: :desc)
      else
        Manifest.includes(:labware_type).printed.not_dispatched
      end
  end

  def show_dispatched?
    @show_dispatched ||= params[:status] == 'dispatched'
  end
  helper_method :show_dispatched?

  def selected_manifests
    @selected_manifests ||= Manifest.where(id: params[:manifest_ids])
  end

  def dispatch_manifests
    begin
      update_dispatch_dates!
      return true
    rescue
      return false
    end
  end

  def update_dispatch_dates!
    Manifest.transaction do
      selected_manifests.each(&:dispatch!)
    end
  end

  def success_message
    "#{'Manifest'.pluralize(selected_manifests.count)} #{selected_manifest_ids} dispatched."
  end

  def selected_manifest_ids
    selected_manifests.map(&:id).join(', ')
  end

end

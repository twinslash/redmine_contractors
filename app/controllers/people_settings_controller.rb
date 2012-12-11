class PeopleSettingsController < ApplicationController
  unloadable
  layout 'admin'
  before_filter :require_admin
  before_filter :find_acl, :only => [:index]
  menu_item :people, :only => :person

  def index
  end

  def update
    settings = Setting.plugin_redmine_contractors
    settings = {} if !settings.is_a?(Hash)
    settings.merge!(params[:settings])
    Setting.plugin_redmine_contractors = settings
    flash[:notice] = l(:notice_successful_update)
    redirect_to :action => 'index', :tab => params[:tab]
  end

  def destroy
    PeopleAcl.delete(params[:id])
    find_acl
    respond_to do |format|
      format.html { redirect_to :controller => 'people_settings', :action => 'index'}
      format.js
    end    
  end

  def autocomplete_for_user
    @principals = Principal.active.like(params[:q]).all(:limit => 100, :order => 'type, login, lastname ASC')
    render :layout => false
  end

  def create
    user_ids = params[:user_ids]
    acls = params[:acls]
    user_ids.each do |user_id|
      PeopleAcl.create(user_id, acls)
    end
    find_acl
    respond_to do |format|
      format.html { redirect_to :controller => 'people_settings', :action => 'index', :tab => 'acl'}
      format.js 
    end 
  end

private

  def find_acl
    @users_acl = PeopleAcl.all
  end

end

class PeopleController < ApplicationController
  unloadable

  Mime::Type.register "text/x-vcard", :vcf

  before_filter :find_person, :only => [:show, :edit, :update, :destroy, :edit_membership, :destroy_membership]
  before_filter :authorize_people, :except => [:avatar, :context_menu]
  before_filter :bulk_find_people, :only => [:context_menu, :bulk_destroy]

  include PeopleHelper

  def index
  	@people = find_people
    @groups = Group.all.sort
    @next_birthdays = Person.next_birthdays

    respond_to do |format|
      format.html {render :partial => 'list_excerpt', :layout => false if request.xhr?}
    end
  end

  def show
    # @person.roles = Role.new(:permissions => [:download_attachments])
    events = Redmine::Activity::Fetcher.new(User.current, :author => @person.user).events(nil, nil, :limit => 10)
    @events_by_day = events.group_by(&:event_date)
    @person_attachments = @person.attachments.select{|a| a != @person.avatar}
    @memberships = @person.memberships.all(:conditions => Project.visible_condition(User.current))
    respond_to do |format|
      format.html
      format.vcf { send_data(person_to_vcard(@person), :filename => "#{@person.nickname}.vcf", :type => 'text/x-vcard;', :disposition => 'attachment') }
    end
  end

  def edit
    @auth_sources = AuthSource.find(:all)
    @membership ||= Member.new
  end

  def new
    @person = Person.new
    @auth_sources = AuthSource.find(:all)
  end

  def update
    (render_403; return false) unless @person.editable_by?(User.current)
    if @person.update_attributes(params[:person])
      @person.user_id = params[:person][:user_id] if params[:person]
      @person.save!
      flash[:notice] = l(:notice_successful_update)
      attach_avatar
      attachments = Attachment.attach_files(@person, params[:attachments])
      render_attachment_warning_if_needed(@person)
      respond_to do |format|
        format.html { redirect_to :action => "show", :id => @person }
        format.api  { head :ok }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit"}
        format.api  { render_validation_errors(@person) }
      end
    end
  end

  def create
    @person  = Person.new
    @person.safe_attributes = params[:person]
    @person.user_id = params[:person][:user_id] if params[:person]
    if @person.save
      attach_avatar

      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_create, :id => view_context.link_to(@person.nickname, person_path(@person)))
          redirect_to(params[:continue] ?
            {:controller => 'people', :action => 'new'} :
            {:controller => 'people', :action => 'show', :id => @person}
          )
        }
        format.api  { render :action => 'show', :status => :created, :location => person_url(@person) }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@person) }
      end
    end
  end

  def destroy
    @person.destroy

    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_successful_delete, :id => view_context.link_to(@person.nickname, person_path(@person)))
        redirect_to({:controller => 'people', :action => 'index'})
      }
    end
  end

  def bulk_destroy
    @people.map(&:destroy)

    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_successful_delete)
        redirect_to({:controller => 'people', :action => 'index'})
      }
    end
  end

  def avatar
    attachment = Attachment.find(params[:id])
    # debugger
    if attachment.readable? && attachment.thumbnailable?
      # images are sent inline
      if defined?(RedmineContacts::Thumbnail) == 'constant'
        target = File.join(attachment.class.thumbnails_storage_path, "#{attachment.id}_#{attachment.digest}_#{params[:size]}.thumb")
        thumbnail = RedmineContacts::Thumbnail.generate(attachment.diskfile, target, params[:size])
      elsif Redmine::Thumbnail.convert_available?
        thumbnail = attachment.thumbnail(:size => params[:size])
      else
        thumbnail = attachment
      end

      if stale?(:etag => attachment.digest)
        send_file (thumbnail || attachment.diskfile), :filename => (request.env['HTTP_USER_AGENT'] =~ %r{MSIE} ? ERB::Util.url_encode(attachment.filename) : attachment.filename),
                                        :type => detect_content_type(attachment),
                                        :disposition => 'inline'
      end

    # attachment_file = attachment
    # if attachment.thumbnailumbnailable? && thumbnail = attachment.thumbnail(:size => params[:size])
    #   if stale?(:etag => thumbnail)
    #     send_file thumbnail,
    #       :filename => (request.env['HTTP_USER_AGENT'] =~ %r{MSIE} ? ERB::Util.url_encode(attachment.filename) : attachment.filename),
    #       :type => detect_content_type(attachment),
    #       :disposition => 'inline'
    #   end
    # else
    #   # No thumbnail for the attachment or thumbnail could not be created
    #   render :nothing => true, :status => 404
    end

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => 404
  end

  def context_menu
    @person = @people.first if (@people.size == 1)
    @can = {:edit =>  @people.collect{|c| User.current.allowed_people_to?(:edit_people, @person)}.inject{|memo,d| memo && d},
            :delete =>  @people.collect{|c| User.current.allowed_people_to?(:delete_people, @person)}.inject{|memo,d| memo && d}
            }

    # @back = back_url
    render :layout => false
  end

private
  def authorize_people
    allowed = case params[:action].to_s
      when "create", "new"
        User.current.allowed_people_to?(:add_people, @person)
      when "update", "edit"
        User.current.allowed_people_to?(:edit_people, @person)
      when "destroy", "bulk_destroy"
        User.current.allowed_people_to?(:delete_people, @person)
      when "index", "show"
        User.current.allowed_people_to?(:view_people, @person)
      else
        false
      end

    if allowed
      true
    else
      deny_access
    end
  end

  def attach_avatar
    if params[:person_avatar]
      params[:person_avatar][:description] = 'avatar'
      @person.avatar.destroy if @person.avatar
      Attachment.attach_files(@person, {"1" => params[:person_avatar]})
      render_attachment_warning_if_needed(@person)
    end
  end

  def detect_content_type(attachment)
    content_type = attachment.content_type
    if content_type.blank?
      content_type = Redmine::MimeType.of(attachment.filename)
    end
    content_type.to_s
  end

  def find_person
    @person = Person.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_people(pages=true)
    # scope = scope.scoped(:conditions => ["#{Person.table_name}.status_id = ?", params[:status_id]]) if (!params[:status_id].blank? && params[:status_id] != "o" && params[:status_id] != "d")
    @status = params[:status] || 1
    scope = Person.logged_with_status(@status)
    scope = scope.search_by_name(params[:name]) if params[:name].present?
    scope = scope.in_group(params[:group_id]) if params[:group_id].present?

    @people_count = scope.count
    @group = Group.find(params[:group_id]) if params[:group_id].present?
    if pages
      @limit =  per_page_option
      @people_pages = Paginator.new(self, @people_count,  @limit, params[:page])
      @offset = @people_pages.current.offset

      scope = scope.scoped :limit  => @limit, :offset => @offset
      @people = scope

      fake_name = @people.first.nickname if @people.length > 0 #without this patch paging does not work
    end

    scope
  end

  def bulk_find_people
    @people = Person.find_all_by_id(params[:id] || params[:ids])

    raise ActiveRecord::RecordNotFound if @people.empty?
    if @people.detect {|person| !person.visible?}
      deny_access
      return
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end


end

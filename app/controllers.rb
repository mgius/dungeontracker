DungeonTracker::App.controllers  do
  layout :main

  get :index do
    if authenticated?
      redirect url_for(:characters)
    else
      render :index
    end
  end

  post :login do
    @user = User.by_email params["email"]
    session[:user] = @user.id
    redirect url_for(:characters)
  end

  get :logout do
    if session
      session[:user] = nil
    end

    redirect url_for(:index)
  end

  get :characters do
    if authenticated?
      @chars = current_user.characters
      current_user.save
      render :characters
    else
      redirect url_for(:index)
    end
  end

  get :all_characters, :map => '/characters/all' do
    if authenticated?
      @chars = Character.all
      current_user.save
      render :characters
    else
      redirect url_for(:index)
    end
  end

  get :new_character do
    if authenticated?
      c = Character.new
      c.user = current_user
      c.save
      redirect url_for(:edit_character, :id => c.id)
    else
      404
    end
  end

  get :toggle_character, :map => '/character/:id/toggle' do
    if authenticated?
      @c = Character.where(id: params[:id]).first
      if @c.nil?
        404
      else
        @c.hidden = !@c.hidden?
        @c.save

        redirect url_for(:characters)
      end
    else
      404
    end
  end

  get :edit_character, :map => '/character/:id/edit' do
    if authenticated?
      @c = Character.where(id: params[:id]).first
      if @c.nil?
        404
      else
        render :edit_character
      end
    else
      redirect url_for(:index)
    end
  end

  post :edit_character, :map => '/character/:id/edit' do
    if authenticated?
      @c = Character.where(id: params[:id]).first
      if @c.nil?
        404
      else
        params.delete "authenticity_token"
        params.delete_if {|k,v| v.empty? }
        params.each_pair do |k,v|
          if v.is_a? Array
            v.delete_if {|i| i.empty? }
          end
        end
        @c.name = params["name"]
        @c.set_data(params, current_user)
        @c.save

        redirect url_for(:edit_character, id: @c.id)
      end
    else
      403
    end
  end

  get :view_character, :map => '/character/:id' do
    @c = Character.where(id: params[:id]).first
    if @c.nil?
      404
    else
      render :view_character
    end
  end
end

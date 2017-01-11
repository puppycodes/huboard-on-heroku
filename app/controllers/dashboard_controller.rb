class DashboardController < ApplicationController
  before_action :login, only: :private
  before_action :determine_auth_scope

  def index
    github_authenticate!(:default) unless github_authenticated?(:default)
    return redirect_to(welcome_path) unless logged_in? && current_user.has_scope?('read:org')
    @private = nil
    @user = gh.users(current_user.login)
    @repos = huboard.all_repos
  end

  def user
    user =   gh.users(params[:user]).raw
    not_found unless user.status == 200

    if logged_in? && current_user.login == params[:user]
      @repos = huboard.repos
    else
      @repos = huboard.repos_by_user(params[:user])
    end

    @user = user.body
    @private = nil
    render :index
  end

  def public
    user = gh.users(params[:user]).raw
    not_found unless user.status == 200
    @private = 0
    @user = user.body
    @repos = huboard.repos_by_user(params[:user]).select {|r| !r['private'] }
    render :index
  end

  def private
    user = gh.users(params[:user]).raw
    not_found unless user.status == 200
    @private = 1
    @user = user.body
    if logged_in? && current_user.login == params[:user]
      @repos = huboard.all_repos.select {|r| r['private'] }
    else
      @repos = huboard.all_repos.select {|r| r['private'] && r['owner']['login'].casecmp(params[:user]) == 0 }
    end
    render :index

  end
  :protected
    def login
      github_authenticate! :private
    end

    def determine_auth_scope
      @auth_scope_private = logged_in? && current_user.has_scope?(:repo)
    end

end

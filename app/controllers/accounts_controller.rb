class AccountsController < ApplicationController
  skip_before_filter :authenticate, :only => [:new, :create]
  
  def new
  end

  def create
  end

  def show
  end

  def index
  end

  def destroy
  end

end

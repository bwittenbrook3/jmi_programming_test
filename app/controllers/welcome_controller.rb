class WelcomeController < ApplicationController
  def index
    @isolates = Isolate.all
  end
end

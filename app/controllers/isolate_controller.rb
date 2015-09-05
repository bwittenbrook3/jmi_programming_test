class IsolateController < ApplicationController
  def show
    @isolate = Isolate.find(params[:id])
    @drugs = Drug.all
  end
end

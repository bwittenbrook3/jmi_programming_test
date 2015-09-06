class IsolateController < ApplicationController
  def show
    @isolate = Isolate.find(params[:id])
    @drugs = Drug.all.order(:name)
  end
end

class SearchesController < ApplicationController
  def dictionary
    render json: Ngram.query(params[:q])
  end

  def structural
    render json: Hanzi.new(params[:q]).result
  end
end

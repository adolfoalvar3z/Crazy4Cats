class WelcomeController < ApplicationController
  def index
    @posts = Post.last(4)
    @consulta = params[:buscar]
    if @consulta.present?
      @posts = Post.search_full_text(@consulta)
    end
  end
end

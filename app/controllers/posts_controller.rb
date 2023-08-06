class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

#usuario ejecutivo
before_action only: [:new, :edit, :create, :update] do
  authorize_request(["super"])
end
#usuario admin
before_action only: [:destroy] do
  authorize_request(["super"])
end

  # GET /posts or /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1 or /posts/1.json
  def show
    @post = Post.find(params[:id])
    @comment = @post.comments.build

    if current_user.present?
    @current_user_id = current_user.id
    end
    @comments = Comment.where(post_id: @post.id).order(created_at: :desc)

    #contar likes y dislikes
    connection = ActiveRecord::Base.connection

    result_likes = connection.execute("SELECT COUNT(*) FROM posts_users WHERE reaccion = 'L' AND post_id = #{@post.id}")
    @likes = result_likes.first['count'].to_i

    result_dislikes = connection.execute("SELECT COUNT(*) FROM posts_users WHERE reaccion = 'D' AND post_id = #{@post.id}")
    @dislikes = result_dislikes.first['count'].to_i

  end

  # GET /posts/new
  def new
    @post = Post.new


  end

  def add_like
    post = Post.find(params[:id])
    user_id = current_user.id

    # Verificamos si el usuario ya ha dado like o dislike al post
    existing_post_user = ActiveRecord::Base.connection.execute("SELECT * FROM posts_users WHERE post_id = #{post.id} AND user_id = #{user_id}").first

    # Si el usuario aún no ha dado like o dislike, agregamos un nuevo reaccion
    if existing_post_user.nil?
      ActiveRecord::Base.connection.execute("
        INSERT INTO posts_users (post_id, user_id, reaccion)
        VALUES (#{post.id}, #{user_id}, 'L')
      ")
      flash[:notice] = "Like agregado correctamente."
    else
      flash[:notice] = "Ya has dado like o dislike a este post."
    end

    redirect_to post_path(post)
  end

def add_dislike
  post = Post.find(params[:id])
  user_id = current_user.id

  # Verificamos si el usuario ya ha dado like o dislike al post
  existing_post_user = ActiveRecord::Base.connection.execute("SELECT * FROM posts_users WHERE post_id = #{post.id} AND user_id = #{user_id}").first

  # Si el usuario aún no ha dado like o dislike, agregamos un nuevo reaccion
  if existing_post_user.nil?
    ActiveRecord::Base.connection.execute("
      INSERT INTO posts_users (post_id, user_id, reaccion)
      VALUES (#{post.id}, #{user_id}, 'D')
    ")
    flash[:notice] = "Like agregado correctamente."
  else
    flash[:notice] = "Ya has dado like o dislike a este post."
  end

  redirect_to post_path(post)
end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    @post.user = current_user
    respond_to do |format|
      if @post.save
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :message)
    end
end

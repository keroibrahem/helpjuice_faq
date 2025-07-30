class ArticlesController < ApplicationController
  def index
    @articles = Article.includes(:category).all
    if params[:search].present?
      keyword = params[:search]
      @articles = @articles.where("title ILIKE ? OR content ILIKE ?", "%#{keyword}%", "%#{keyword}%")
    end
    if params[:category_id].present?
      @articles = @articles.where(category_id: params[:category_id])
    end
    render json: @articles.as_json(include: :category)
  end

  def show
    @article = Article.find(params[:id])
    render json: @article.as_json(include: :category)
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      render json: @article, status: :created
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  def update
    @article = Article.find(params[:id])
    if @article.update(article_params)
      render json: @article
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    head :no_content
  end

  private

  def article_params
    params.require(:article).permit(:title, :content, :category_id)
  end
end
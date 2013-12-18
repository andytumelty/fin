class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  # GET /categories
  # GET /categories.json
  def index
    @categories = current_user.categories.all
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  def create
    @category = Category.new(category_params)
    @category.user = current_user

    if @category.save
      redirect_to categories_url, notice: 'Category was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /categories/1
  def update
    if @category.update(category_params)
      redirect_to categories_url, notice: 'Category was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
    redirect_to categories_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name)
    end
end

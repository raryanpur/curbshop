class ItemsController < ApplicationController

  #When using operators in Ruby, make sure to put a space on each side of the operator it self
  #When using boolean operators, like the ! symbol, Ruby Style is to leave no space after the operator

  #The before_filter method still works, but the new Rails 4 method is called before_action
  before_filter :authenticate_user!, :except => [:shopping,:show]

  	def shopping
        @bid = Bid.new
        @categories = Category.all 
        #Cleaned this up a bit
        if params[:category_id].blank?
          @items = Item.all
        else
          @items = Item.where(category_id: params[:category_id], sold: false).to_a
        end
  	end

  	def new
      @user_id = current_user.id 
      @instagram_images = current_user.instagram_images('thumbnail')
      @user = User.find(@user_id)
      @item = Item.new
      3.times { @item.item_images.build }   
  	end

    def create
      @item = Item.new(new_safe_item_params)
      if @item.save
        flash[:notice] = "Success! Your item is now on your curb."
        redirect_to @item
      else
        render :new
      end
    end

    def curb
      @items_for_sale = Item.where user_id: current_user.id
      @items_bid_on = Bid.select(:item_id).distinct.where(user_id: current_user.id)
    end

    def show
      @item = Item.find(params[:id])
      @bid = Bid.new
    end

    def destroy
      Item.find(params[:id]).destroy
      redirect_to curb_path
    end

    def edit
      @item = Item.find(params[:id])
      @instagram_images = current_user.instagram_images
      @user_id = current_user.id 
      @user = User.find(@user_id)
      3.times { @item.item_images.build }  
    end

    def update
      @item = Item.update(params[:id], update_safe_item_params)
      if @item.save
        flash[:notice] = "Success! Your item has been updated."  
        redirect_to @item
      else
        flash[:notice] = "We couldn't update your item. Please try again."
        render :edit
      end
    end

    private

      def new_safe_item_params
        params.require(:item).permit(:category_id, :description, :picture, :item_image, :user_id, :starting_price, :city, item_images_attributes: [:image]) 
      end
      
      def update_safe_item_params
        item_params = params.require(:item).permit(:category_id,:picture, :starting_price, :description, :city)
      end

end

class EntriesController < ApplicationController
  before_action :set_entry, only: %i[ show edit update destroy ]
  require 'rest-client'

  # GET /entries or /entries.json
  def index
    @entries = Entry.all.reverse.each.group_by(&:day)
  end

  # GET /entries/1 or /entries/1.json
  def show
  end

  # GET /entries/new
  def new
    @entry = Entry.new
  end

  # GET /entries/1/edit
  def edit
  end

  # POST /entries or /entries.json
  def create
    #getting values from form
    mealType = entry_params['food_meal_type']
    upc = entry_params['food_upc_code']
    inputQuantity = entry_params['food_quantity']
    productName = entry_params['food_name']

    #If UPC and quantity entered whilst product name is empty - Fetch with UPC (Open food facts API)
    if mealType.present? && upc.present? && inputQuantity.present? && productName.empty?
      #API URL
      url = "https://world.openfoodfacts.org/api/v0/product/#{upc}.json"
      
      #get request sent to open food facts api
      response = RestClient.get(url)

      if response.present?
        #getting values from JSON
        resGenericName = JSON.parse(response)['product']['generic_name']
        resProductName = JSON.parse(response)['product']['product_name']
        resCalories = JSON.parse(response)['product']['nutriments']['energy-kcal_100g']
        resProteins = JSON.parse(response)['product']['nutriments']['proteins_100g']
        resCarbohydrates = JSON.parse(response)['product']['nutriments']['carbohydrates_100g']
        resFibre = JSON.parse(response)['product']['nutriments']['fiber_100g']
        resFat = JSON.parse(response)['product']['nutriments']['fat_100g']

        begin
          #Calculating calories for inputed quantity of product
          if resCalories.present? 
            caloriesTotal = ((Float(inputQuantity) / 100) * Float(resCalories)).round(2)
          else
            caloriesTotal = 0
          end

          #Calculating proteins for inputed quantity of product
          if resProteins.present?
            proteinsTotal = ((Float(inputQuantity) / 100) * Float(resProteins)).round(2)
          else
            proteinsTotal = 0
          end

          #Calculating carbohydrates for inputed quantity of product
          if resCarbohydrates.present?
            carbsTotal = ((Float(inputQuantity) / 100) * Float(resCarbohydrates)).round(2)
          else
            carbsTotal = 0
          end

          #Calculating fibre for inputed quantity of product
          if resFibre.present?
            fibreTotal = ((Float(inputQuantity) / 100) * Float(resFibre)).round(2)
          else
            fibreTotal = 0
          end

          #Calculating fat for inputed quantity of product
          if resFat.present?
            fatsTotal = ((Float(inputQuantity) / 100) * Float(resFat)).round(2)
          else
            fatsTotal = 0
          end

          #Establishing product name
          if resGenericName.present?
          elsif resProductName.present?
            resGenericName = resProductName
          else
            resGenericName = "Product name could not be retrieved"
          end

          #Inserting new entry to db
          @entry = Entry.new(:food_meal_type => mealType, :food_name => resGenericName, :food_calories => caloriesTotal, :food_protein => proteinsTotal, :food_carbohydrates => carbsTotal, :food_fats => fatsTotal, :food_fibre => fibreTotal, :food_upc_code => upc, :food_quantity => inputQuantity)

          respond_to do |format|
            if @entry.save
              format.html { redirect_to entry_url(@entry), notice: "Entry was successfully created." }
              format.json { render :show, status: :created, location: @entry }
            else
              format.html { render :new, status: :unprocessable_entity }
              format.json { render json: @entry.errors, status: :unprocessable_entity }
            end
          end
        rescue => e
          respond_to do |format|
            format.html { redirect_to entries_url, notice: e }
            format.json { head :no_content }
          end
        end
      end
    end

    #If product name and quantity entered whilst upc is empty - Fetch with product name (Spoonacular API)
    if mealType.present? && productName.present? && inputQuantity.present? && upc.empty?
      #API URL
      url = "https://calorieninjas.p.rapidapi.com/v1/nutrition?query=#{productName}"
      
      #get request sent to open food facts api
      response = RestClient.get(url, headers={
        'X-RapidAPI-Key': '62b46db563msh3428ab2fca10affp1f4688jsn40fdc1b419c4', 
        'X-RapidAPI-Host': 'calorieninjas.p.rapidapi.com'
      })

      if response.present? && !response.nil? #FIX BOTH CONDITIONS TO ENSURE THAT EMPTY RESPONSE DOES NOT TRIGGER THE CODE
        Rails.logger.info(JSON.parse(response))
        Rails.logger.info(!response.nil?)
        #getting values from JSON
        resServingSize = JSON.parse(response)['items'][0]['serving_size_g']
        resCalories = JSON.parse(response)['items'][0]['calories']
        resProteins = JSON.parse(response)['items'][0]['protein_g']
        resCarbohydrates = JSON.parse(response)['items'][0]['carbohydrates_total_g']
        resFibre = JSON.parse(response)['items'][0]['fiber_g']
        resFat = JSON.parse(response)['items'][0]['fat_total_g']
        
        begin
          #Calculating calories for inputed quantity of product
          if resCalories.present? 
            caloriesTotal = ((Float(inputQuantity) / resServingSize) * Float(resCalories)).round(2)
          else
            caloriesTotal = 0
          end

          #Calculating proteins for inputed quantity of product
          if resProteins.present?
            proteinsTotal = ((Float(inputQuantity) / resServingSize) * Float(resProteins)).round(2)
          else
            proteinsTotal = 0
          end

          #Calculating carbohydrates for inputed quantity of product
          if resCarbohydrates.present?
            carbsTotal = ((Float(inputQuantity) / resServingSize) * Float(resCarbohydrates)).round(2)
          else
            carbsTotal = 0
          end

          #Calculating fibre for inputed quantity of product
          if resFibre.present?
            fibreTotal = ((Float(inputQuantity) / resServingSize) * Float(resFibre)).round(2)
          else
            fibreTotal = 0
          end

          #Calculating fat for inputed quantity of product
          if resFat.present?
            fatsTotal = ((Float(inputQuantity) / resServingSize) * Float(resFat)).round(2)
          else
            fatsTotal = 0
          end

          #Inserting new entry to db
          @entry = Entry.new(:food_meal_type => mealType, :food_name => productName, :food_calories => caloriesTotal, :food_protein => proteinsTotal, :food_carbohydrates => carbsTotal, :food_fats => fatsTotal, :food_fibre => fibreTotal, :food_upc_code => upc, :food_quantity => inputQuantity)

          respond_to do |format|
            if @entry.save
              format.html { redirect_to entry_url(@entry), notice: "Entry was successfully created." }
              format.json { render :show, status: :created, location: @entry }
            else
              format.html { render :new, status: :unprocessable_entity }
              format.json { render json: @entry.errors, status: :unprocessable_entity }
            end
          end
        rescue => e
          respond_to do |format|
            format.html { redirect_to entries_url, notice: e }
            format.json { head :no_content }
          end
        end
      end
    end

    if mealType.present? && productName.present? && inputQuantity.present? && upc.present?
      respond_to do |format|
        format.html { redirect_to entries_url, notice: 'Please provide only product name or product code' }
        format.json { head :no_content }
      end
    end
  end

  # PATCH/PUT /entries/1 or /entries/1.json
  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to entry_url(@entry), notice: "Entry was successfully updated." }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1 or /entries/1.json
  def destroy
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to entries_url, notice: "Entry was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def entry_params
      params.require(:entry).permit(:food_meal_type, :food_name, :food_calories, :food_protein, :food_carbohydrates, :food_fats, :food_fibre, :food_upc_code, :food_quantity)
    end
end  
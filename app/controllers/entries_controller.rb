class EntriesController < ApplicationController
  require 'rest-client'

  before_action :authenticate 
  before_action :set_entry, only: %i[ show edit update destroy ]
  
  #User authentication - only logged in user can access the entries view
  def authenticate
    unless logged_in?
      respond_to do |format|
        format.html { redirect_to "/login", notice: "You must be logged in to access this section" }
        format.json { head :no_content }
      end
    end
  end

  # GET user specific /entries or /entries.json
  def index
    #delays page load on mobiles and tablets - allows animatino to complete and loads the page
    if device == "tablet" || device == "mobile"
      sleep 0.385 
    end
    
    #Used to get user specific entries for current week group them by day then reverse to display newest first
    @entries = Entry.where(user_id: current_user.id).where("updated_at >= ?", Date.today.at_beginning_of_week).reverse.each.group_by(&:day)

    #Entries export
    respond_to do |format|
      format.html
      format.csv { send_data Entry.where(user_id: current_user.id).to_csv, filename: "Entries - #{DateTime.now.strftime("%d-%m-%Y, %H:%M")}.csv"}
    end
  end

  # GET /entries/1 or /entries/1.json
  def show
    #delays page load on mobiles and tablets - allows animatino to complete and loads the page
    if device == "tablet" || device == "mobile"
      sleep 0.385 
    end

    #Blocks access to entry if user does not own it
    restrict_access if @entry.user_id != @current_user.id
  end

  # GET /entries/new
  def new
    #delays page load on mobiles and tablets - allows animatino to complete and loads the page
    if device == "tablet" || device == "mobile"
      sleep 0.385 
    end

    @scannerHidden = false
    @entry = Entry.new
  end

  # GET /entries/1/edit
  def edit
    #delays page load - lets new entry animation complete and loads the page
    if device == "tablet" || device == "mobile"
      sleep 0.385 
    end

    #Blocks access to entry if user does not own it
    restrict_access if @entry.user_id != @current_user.id

    @scannerHidden = true
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
      fetch_data_with_upc(upc, action="create")
    end

    #If product name and quantity entered whilst upc is empty - Fetch with product name (Spoonacular API)
    if mealType.present? && productName.present? && inputQuantity.present? && upc.empty?
      fetch_data_with_product_name(productName, action="create")
    end

    #If product name and product code entered at the same time
    if mealType.present? && productName.present? && inputQuantity.present? && upc.present?
      respond_to do |format|
        format.html { redirect_to entries_url, notice: 'Please provide only product name or product code' }
        format.json { head :no_content }
      end
    end
  end

  # PATCH/PUT /entries/1 or /entries/1.json
  def update
    #Blocks access to entry if user does not own it
    restrict_access if @entry.user_id != @current_user.id

    #getting values from form
    mealType = entry_params['food_meal_type']
    upc = entry_params['food_upc_code']
    inputQuantity = entry_params['food_quantity']
    productName = entry_params['food_name']

    #If UPC and quantity entered whilst product name is empty - Fetch with UPC (Open food facts API)
    if mealType.present? && upc.present? && inputQuantity.present? && productName.present?
      fetch_data_with_upc(upc, action="update")
    end

    #If product name and quantity entered whilst upc is empty - Fetch with product name (Spoonacular API)
    if mealType.present? && productName.present? && inputQuantity.present? && upc.empty?
      fetch_data_with_product_name(productName, action="update")
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

  #Fetches product data with upc from OpenFoodFacts API
  def fetch_data_with_upc(upc, action)
    #API URL
    url = "https://world.openfoodfacts.org/api/v0/product/#{upc}.json"
      
    #get request sent to OpenFoodFacts API
    response = RestClient.get(url)

    #If response is present
    if JSON.parse(response)['product'].present?
      get_upc_nutrients(response, action)
    end

    #If response is not present display notice
    if !JSON.parse(response)['product'].present?
      respond_to do |format|
        format.html { redirect_to entries_url, notice: 'Could not retrieve data - verify entered product code.' }
        format.json { head :no_content }
      end
    end
  end

  #Getting values from OpenFoodFacts API response
  def get_upc_nutrients(response, action)
    #getting values from JSON
    resServingSize = 100
    resGenericName = JSON.parse(response)['product']['product_name']
    resCalories = JSON.parse(response)['product']['nutriments']['energy-kcal_100g']
    resProteins = JSON.parse(response)['product']['nutriments']['proteins_100g']
    resCarbohydrates = JSON.parse(response)['product']['nutriments']['carbohydrates_100g']
    resFibre = JSON.parse(response)['product']['nutriments']['fiber_100g']
    resFat = JSON.parse(response)['product']['nutriments']['fat_100g']

    calculate_nutrients(resServingSize, resGenericName, resCalories, resProteins, resCarbohydrates, resFibre, resFat, action)
  end

  #Fetches product data with upc from CalorieNinjas API
  def fetch_data_with_product_name(productName, action)
    #API URL
    url = "https://calorieninjas.p.rapidapi.com/v1/nutrition?query=#{productName}"
    
    #get request sent to CalorieNinjas API
    response = RestClient.get(url, headers={
      'X-RapidAPI-Key': ENV["CALORIE_NINJA_API_KEY"], 
      'X-RapidAPI-Host': 'calorieninjas.p.rapidapi.com'
    })

    #Verifys that response is present before proceding
    if JSON.parse(response)['items'].present?
      get_product_nutrients(response, action)
    end

    #If response is not present display notice
    if !JSON.parse(response)['items'].present?
      respond_to do |format|
        format.html { redirect_to entries_url, notice: 'Could not retrieve data - check product name spelling.' }
        format.json { head :no_content }
      end
    end
  end

  #Getting values from CalorieNinjas API response
  def get_product_nutrients(response, action)
    #getting values from JSON
    resServingSize = JSON.parse(response)['items'][0]['serving_size_g']
    resGenericName = entry_params['food_name']
    resCalories = JSON.parse(response)['items'][0]['calories']
    resProteins = JSON.parse(response)['items'][0]['protein_g']
    resCarbohydrates = JSON.parse(response)['items'][0]['carbohydrates_total_g']
    resFibre = JSON.parse(response)['items'][0]['fiber_g']
    resFat = JSON.parse(response)['items'][0]['fat_total_g']

    calculate_nutrients(resServingSize, resGenericName, resCalories, resProteins, resCarbohydrates, resFibre, resFat, action)
  end

  #Calculates nutrients with fetched data - upc
  def calculate_nutrients(resServingSize, resGenericName, resCalories, resProteins, resCarbohydrates, resFibre, resFat, action)
    #getting values from form
    mealType = entry_params['food_meal_type']
    upc = entry_params['food_upc_code']
    inputQuantity = Float(entry_params['food_quantity'])
    
    begin
      #Calculating calories for inputed quantity of product
      if resCalories.present? 
        caloriesTotal = ((inputQuantity / resServingSize) * resCalories).round(2)
      else
        caloriesTotal = 0
      end

      #Calculating proteins for inputed quantity of product
      if resProteins.present?
        proteinsTotal = ((inputQuantity / resServingSize) * resProteins).round(2)
      else
        proteinsTotal = 0
      end

      #Calculating carbohydrates for inputed quantity of product
      if resCarbohydrates.present?
        carbsTotal = ((inputQuantity / resServingSize) * resCarbohydrates).round(2)
      else
        carbsTotal = 0
      end

      #Calculating fibre for inputed quantity of product
      if resFibre.present?
        fibreTotal = ((inputQuantity / resServingSize) * resFibre).round(2)
      else
        fibreTotal = 0
      end

      #Calculating fat for inputed quantity of product
      if resFat.present?
        fatsTotal = ((inputQuantity / resServingSize) * resFat).round(2)
      else
        fatsTotal = 0
      end

      if action == "create"
        #Inserts entry
        insert(mealType, resGenericName, caloriesTotal, proteinsTotal, carbsTotal, fatsTotal, fibreTotal, upc, inputQuantity)
      elsif action == "update"
        #Updates entry
        modify(mealType, resGenericName, caloriesTotal, proteinsTotal, carbsTotal, fatsTotal, fibreTotal, upc, inputQuantity)
      end
    rescue => e
      respond_to do |format|
        format.html { redirect_to entries_url, notice: e }
        format.json { head :no_content }
      end
    end
  end

  #Insert calculated data into db as an entry
  def insert(mealType, resGenericName, caloriesTotal, proteinsTotal, carbsTotal, fatsTotal, fibreTotal, upc, inputQuantity)
    #Inserting new entry to db
    @entry = current_user.entries.new(:food_meal_type => mealType, :food_name => resGenericName.split(' ').map {|w| w.capitalize }.join(' '), :food_calories => caloriesTotal, :food_protein => proteinsTotal, :food_carbohydrates => carbsTotal, :food_fats => fatsTotal, :food_fibre => fibreTotal, :food_upc_code => upc, :food_quantity => inputQuantity)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to entry_url(@entry), notice: "Entry was successfully created." }
        format.json { render :show, status: :created, location: @entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  #Update entry with calculated data
  def modify(mealType, resGenericName, caloriesTotal, proteinsTotal, carbsTotal, fatsTotal, fibreTotal, upc, inputQuantity)
    respond_to do |format|
      if @entry.update(:food_meal_type => mealType, :food_name => resGenericName.split(' ').map {|w| w.capitalize }.join(' '), :food_calories => caloriesTotal, :food_protein => proteinsTotal, :food_carbohydrates => carbsTotal, :food_fats => fatsTotal, :food_fibre => fibreTotal, :food_upc_code => upc, :food_quantity => inputQuantity)
        format.html { redirect_to entry_url(@entry), notice: "Entry was successfully updated." }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
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
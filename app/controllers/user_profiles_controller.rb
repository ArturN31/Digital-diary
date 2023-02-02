class UserProfilesController < ApplicationController
  before_action :authenticate 
  before_action :set_user_profile, only: %i[ show edit update destroy ]
  
  #User authentication - only logged in user can access the entries view
  def authenticate
    unless logged_in?
      respond_to do |format|
        format.html { redirect_to "/login", notice: "You must be logged in to access this section" }
        format.json { head :no_content }
      end
    end
  end

  # GET /user_profiles or /user_profiles.json
  def index
    #delays page load on mobiles and tablets - allows animatino to complete and loads the page
    if device == "tablet" || device == "mobile"
      sleep 0.385 
    end

    @user_profiles = UserProfile.where(user_id: current_user.id)
  end

  # GET /user_profiles/1 or /user_profiles/1.json
  def show
    #delays page load on mobiles and tablets - allows animatino to complete and loads the page
    if device == "tablet" || device == "mobile"
      sleep 0.385 
    end

    #Blocks access to entry if user does not own it
    restrict_access if @user_profile.user_id != current_user.id
  end

  # GET /user_profiles/new
  def new
    if UserProfile.where(user_id: current_user.id).empty? 
      @user_profile = UserProfile.new
    else
      respond_to do |format|
        format.html { redirect_to user_profiles_url, notice: "You already have a profile." }
        format.json { head :no_content }
      end
    end
    
  end

  # GET /user_profiles/1/edit
  def edit
    #delays page load on mobiles and tablets - allows animatino to complete and loads the page
    if device == "tablet" || device == "mobile"
      sleep 0.385 
    end
    
    #Blocks access to entry if user does not own it
    restrict_access if @user_profile.user_id != current_user.id
  end

  # POST /user_profiles or /user_profiles.json
  def create
    calculation(action="create")

    respond_to do |format|
      if @user_profile.save
        format.html { redirect_to user_profiles_url, notice: "User profile was successfully created." }
        format.json { render :show, status: :created, location: @user_profile }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_profiles/1 or /user_profiles/1.json
  def update
    calculation(action="update")
  end

  # DELETE /user_profiles/1 or /user_profiles/1.json
  def destroy
    @user_profile.destroy

    respond_to do |format|
      format.html { redirect_to user_profiles_url, notice: "User profile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def calculation(action)
    #getting values from form
    userWeight = user_profile_params['user_weight']
    userHeight = user_profile_params['user_height']
    userAge = user_profile_params['user_age']
    userGender = user_profile_params['user_gender']
    userPal = user_profile_params['user_pal_value']

    #Establishing PAL values for chosen activity level
    case userPal
    when "Sedentary or inactive (<5000 steps)"
      userPalMin = 1.4
      userPalMax = 1.59
    when "Low active (5000-7499 steps)"
      userPalMin = 1.6
      userPalMax = 1.79
    when "Somewhat active (7500-9999 steps)"
      userPalMin = 1.8
      userPalMax = 1.99
    when "Active (10,000-12,500 steps)"
      userPalMin = 2.0
      userPalMax = 2.19
    when "Highly Active (>12,500 steps)"
      userPalMin = 2.2
      userPalMax = 2.4
    end

    #Calculating Total Daily Energy Expenditure
    case userGender
    when "Male" #Calculates TDEE for males
      calorieIntakeMin = ((10 * Float(userWeight)) + (6.25 * Float(userHeight)) - (5 * Float(userAge)) + 5) * userPalMin #Lower end of calories
      calorieIntakeMax = ((10 * Float(userWeight)) + (6.25 * Float(userHeight)) - (5 * Float(userAge)) + 5) * userPalMax #Higher end of calories
    when "Female" #Calculates TDEE for females
      calorieIntakeMin = ((10 * Float(userWeight)) + (6.25 * Float(userHeight)) - (5 * Float(userAge)) - 161) * userPalMin #Lower end of calories
      calorieIntakeMax = ((10 * Float(userWeight)) + (6.25 * Float(userHeight)) - (5 * Float(userAge)) - 161) * userPalMax #Higher end of calories
    end

    if action == "create"
      insert(userWeight, userHeight, userAge, userGender, userPal, calorieIntakeMin, calorieIntakeMax)
    end
    if action == "update"
      modify(userWeight, userHeight, userAge, userGender, userPal, calorieIntakeMin, calorieIntakeMax)
    end
  end

  def insert(userWeight, userHeight, userAge, userGender, userPal, calorieIntakeMin, calorieIntakeMax)
    @user_profile = current_user.user_profiles.new(:user_weight => userWeight, :user_height => userHeight, :user_age => userAge, :user_gender => userGender, :user_pal_value => userPal, :user_min_calories => calorieIntakeMin, :user_max_calories => calorieIntakeMax, :user_id => current_user.id)
  end

  def modify(userWeight, userHeight, userAge, userGender, userPal, calorieIntakeMin, calorieIntakeMax)
    respond_to do |format|
      if @user_profile.update(:user_weight => userWeight, :user_height => userHeight, :user_age => userAge, :user_gender => userGender, :user_pal_value => userPal, :user_min_calories => calorieIntakeMin, :user_max_calories => calorieIntakeMax, :user_id => current_user.id)
        format.html { redirect_to user_profile_url(@user_profile), notice: "User profile was successfully updated." }
        format.json { render :show, status: :ok, location: @user_profile }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_profile
      @user_profile = UserProfile.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_profile_params
      params.require(:user_profile).permit(:user_weight, :user_height, :user_age, :user_gender, :user_pal_value, :user_min_calories, :user_max_calories, :user_id => current_user.id)
    end
end

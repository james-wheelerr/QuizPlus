class StaticPagesController < ApplicationController
  
  def home
    
    numOfQuestionsAsInt = params[:numOfQuestions].to_i 
    numOfQuestionsAsInt != 4 ? @numOfQuestions = numOfQuestionsAsInt : @numOfQuestions = 4 
    
    if params[:LinuxPres] == 'true'
      @LinuxPres = true;
    end
    if params[:DevOpsPres] == 'true'
      @DevOpsPres = true;
    end
    if params[:SQLPres] == 'true'
      @SQLPres = true;
    end
    if params[:BASHPres] == 'true'
      @BASHPres = true;
    end
    
    if params[:difficulty] == 'Medium'
      @difficultySetting = 'Medium'
    elsif params[:difficulty] == 'Hard'
      @difficultySetting = 'Hard'
    else
      @difficultySetting = 'Easy'
    end
    
    @numOptions = [4,5,6,7,8]
    @categoryOptions = ["Linux", "DevOps", "SQL", "BASH"]
    @difficulty = ['Easy', 'Medium', 'Hard']
    
    
  end
end

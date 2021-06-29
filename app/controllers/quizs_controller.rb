class QuizsController < ApplicationController
  
  require 'json'
  
  def new
    
    params[:numOfQuestions] != nil ? @numOfQuestions = params[:numOfQuestions].to_i : @numOfQuestions = 4 
    
    # array stores Question objects
    @questionsForQuiz = Array.new
    
    if params[:questions] != nil
      # drops fist element it finds as this is a blank space
      paramQuestions = params[:questions].split("q_").drop(1)
      
      # read the written to file, in order to get previous questions
      quizFile = File.read('quiz.json')
      quizQuestions = JSON.parse(quizFile)
    
      quizQuestions.each do |question|
        
        @questionsForQuiz.push(question) if paramQuestions.include? (question['id'].to_s)
        
      end
    else
      
      potentialCategories = ['Linux', 'DevOps', 'SQL', 'BASH']
      
      @LinuxPresent, @DevOpsPresent, @SQLPresent, @BASHPresent = false;
      
      categoryString = nil
      
      if params[:Linux] == 'true'
        @LinuxPresent = true
        categoryString == nil ? categoryString = '-d category=Linux ' : categoryString += '-d category=Linux '
      end
      if params[:DevOps] == 'true'
        @DevOpsPresent = true
        categoryString == nil ? categoryString = '-d category=DevOps ' : categoryString += '-d category=DevOps '
      end
      if params[:SQL] == 'true'
        @SQLPresent = true
        categoryString == nil ? categoryString = '-d category=SQL ' : categoryString += '-d category=SQL '
      end
      if params[:BASH] == 'true'
        @BASHPresent = true
        categoryString == nil ? categoryString = '-d category=BASH ' : categoryString += '-d category=BASH '
      end
      
      if params[:difficulty] == 'Medium'
        @difficulty = 'Medium'
        categoryString == nil ? categoryString = '-d difficulty=Medium ' : categoryString += '-d difficulty=Medium '
      elsif params[:difficulty] == 'Hard'
        @difficulty = 'Hard'
        categoryString == nil ? categoryString = '-d difficulty=Hard ' : categoryString += '-d difficulty=Hard '
      else
        @difficulty = 'Easy'
        categoryString == nil ? categoryString = '-d difficulty=Easy ' : categoryString += '-d difficulty=Easy '
      end
        
      quizQuestions = loadJSON(categoryString)
      
      while (@questionsForQuiz.length() != @numOfQuestions)
        randomQuestionIndex = rand(0 ... quizQuestions.length())
        individualEntry = quizQuestions[randomQuestionIndex]
        @questionsForQuiz.push(individualEntry) if !@questionsForQuiz.include?(individualEntry)
      end
      
    end
  end
  
  def results
    
    @score = 0;
    
    quizFile = File.read('quiz.json')
    quizQuestions = JSON.parse(quizFile)
    
    @questionsAnswered = ''
    @questionCount = 0
    
    params.each do |questionParam, questionAnswer|
      
      if questionParam.start_with?('q_')
        
        @questionsAnswered += questionParam
        @questionCount += 1
        
        questionNum = questionParam.sub('q_', '')
        
        quizQuestions.each do |question|
          
          if question['id'] == questionNum.to_i
            # iterates through correct answers hash
            # note: correct_answer field is ocassional null hence the need for this loop
            question['correct_answers'].each do |ansKey, boolVal|
              @score += 1 if ansKey.start_with?(questionAnswer) && boolVal == 'true'
            end
          end
        
        end
        
      end
    end
    
    reversedOrder = cookieOperations(@score, @questionCount)
    
    @listOfScores = Array.new
    
    count = 0;
    
    reversedOrder.each do |i|
      splitEntry = i.split('#')
      @listOfScores.push('At ' + splitEntry[0] + ' you answered ' + splitEntry[1] + ' questions correctly') unless count > 4
      count += 1
    end
    
    @numOfQuestions = params[:numOfQuestions]
    @difficulty = params[:difficulty]
    @LinuxPresent = params[:LinuxPres]
    @DevOpsPresent = params[:DevOpsPres]
    @SQLPresent = params[:SQLPres]
    @BASHPresent = params[:BASHPres]
    
  end
  
  def cookieOperations(score, questionCount)
    currentTime = Time.new
    
    # as time is default UTC (Melbourne +10)
    hour = currentTime.hour + 10
    hourStr = ''
    
    hour > 12 ? hourStr = (hour - 12).to_s + "pm" : hourStr = hour.to_s + "am"
    
    day = currentTime.day
    month = currentTime.month
    year = currentTime.year
    
    strForCookie = hourStr + ',' + day.to_s + '-' + month.to_s + '-' + year.to_s + ',#' + score.to_s + '/' + questionCount.to_s
    
    scoreCookie = cookies["usrScores"]
    
    if scoreCookie
      
      scoreCookie += "$" + strForCookie
    else
      scoreCookie = strForCookie
    end
    
    # expires after 5 days
    cookies["usrScores"] = {value: scoreCookie, expires: 120.hour.from_now}
    
    scoresFromCookie = scoreCookie.split('$')
    # reversed so in order of most recent entries
    reversedOrder = scoresFromCookie.reverse()
  end
  
  def loadJSON(stringOfCategories)
    
    quizFile = File.read('quiz.json')
    
    if stringOfCategories != nil
      apiCall = `curl https://quizapi.io/api/v1/questions -G -d apiKey=RByCcRWApJ10wtRYYIKs1mf6VLo5Og22xINigoCU -d limit=15 #{stringOfCategories}`
    else
      apiCall = `curl https://quizapi.io/api/v1/questions -G -d apiKey=RByCcRWApJ10wtRYYIKs1mf6VLo5Og22xINigoCU -d limit=15 -d category=Linux -d difficulty=Easy`
    end
  
    if apiCall == nil
      quizQuestions = JSON.parse(quizFile)
    else
      quizQuestions = JSON.parse(apiCall)
      # writes to the file so that the quiz can be redone
      File.write('quiz.json', JSON.dump(quizQuestions))
    end
    
    return quizQuestions
  end
  
end
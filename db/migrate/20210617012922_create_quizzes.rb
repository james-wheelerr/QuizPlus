class CreateQuizzes < ActiveRecord::Migration[5.2]
  def change
    create_table :quizzes do |t|
      t.integer :num_of_questions
      t.integer :num_of_correct_ans

      t.timestamps
    end
  end
end

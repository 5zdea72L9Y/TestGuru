class TestPassage < ApplicationRecord

  SUCCESS_PERCENTAGES = 85

  belongs_to :test
  belongs_to :user

  belongs_to :current_question, class_name: :Question, optional: true

  validates :score, presence: true

  before_validation :before_validation_set_first_question, except: :result

  def accept!(answer_ids)
    if correct_answer?(answer_ids)
      self.correct_questions += 1
    end
    save
  end

  def completed?
    current_question.nil?
  end

  def result_in_percentages
    (correct_questions * 100.0 / test.questions.count).round(2)
  end

  def successful?
    result_in_percentages >= SUCCESS_PERCENTAGES if completed?
  end

  private

  def before_validation_set_first_question
    self.current_question = next_question
  end

  def correct_answer?(answer_ids)
    correct_answers.ids.sort == answer_ids.to_a.map(&:to_i).sort
  end

  def next_question
    if current_question.nil?
      test.questions.first
    else
      test.questions.order(:id).where('id > ?', current_question.id).first
    end
  end

  def correct_answers
    current_question.answers.correct
  end
end
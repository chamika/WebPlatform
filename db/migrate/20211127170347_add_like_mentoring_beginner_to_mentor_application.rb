class AddLikeMentoringBeginnerToMentorApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :mentor_applications, :like_mentoring_beginner, :boolean,  default: false, comment: 'Whether to like mentoring a beginner in tech'
  end
end

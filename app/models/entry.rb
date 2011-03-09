class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  belongs_to :project

  # TODO: Check presence of :task
  validates_presence_of :day, :project, :start, :end

  accepts_nested_attributes_for :task, :project, :user
  attr_accessible :day, :description, :start, :end, :task_id, :project_id,
    :user_id, :billable

end

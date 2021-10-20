module StudentTaskHelper

  def get_review_grade_info(participant)
    info = ''
    if participant.try(:review_grade).try(:grade_for_reviewer).nil? ||
       participant.try(:review_grade).try(:comment_for_reviewer).nil?
      result = "N/A"
    else
      info = "Score: " + participant.try(:review_grade).try(:grade_for_reviewer).to_s + "/100\n"
      info += "Comment: " + participant.try(:review_grade).try(:comment_for_reviewer).to_s
      info = truncate(info, length: 1500, omission: '...')
      result = "<img src = '/assets/info.png' title = '" + info + "'>"
    end
    result.html_safe
  end

  def self.get_submission_grade_info(participant)
    # Gets the submission grade for a participant from the grade column of the participant table
    # If no grade is assigned to the participant, it returns "N/A"
    # All returns are in string to keep them HTML safe 
    info = ''
    if participant.try(:grade).nil?
      info = "N/A"
    else
      info = participant.try(:grade).to_s
    end
  info
  end

  def check_reviewable_topics(assignment)
    return true if !assignment.topics? and assignment.current_stage != "submission"
    sign_up_topics = SignUpTopic.where(assignment_id: assignment.id)
    sign_up_topics.each {|topic| return true if assignment.can_review(topic.id) }
    false
  end

  def unsubmitted_self_review?(participant_id)
    self_review = SelfReviewResponseMap.where(reviewer_id: participant_id).first.try(:response).try(:last)
    return !self_review.try(:is_submitted) if self_review
    true
  end

  def get_awarded_badges(participant)
    info = ''
    participant.awarded_badges.each do |awarded_badge|
      badge = awarded_badge.badge
      # In the student task homepage, list only those badges that are approved
      if awarded_badge.approved?
        info += '<img width="30px" src="/assets/badges/' + badge.image_name + '" title="' + badge.name + '" />'
      end
    end
    info.html_safe
  end

  def review_deadline?(assignment)
    assignment.find_due_dates('review').present?
  end
end

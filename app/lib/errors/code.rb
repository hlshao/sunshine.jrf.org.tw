class Errors::Code

  STATUS = {
    auth_failed: 401,
    court_not_exist: 400,
    court_already_judged: 400,
    court_rating_score_blank: 400,
    command_score_blank: 400,
    cant_reset_password: 400,
    data_invalid: 400,
    data_create_fail: 400,
    data_update_fail: 400,
    data_delete_fail: 400,
    data_not_found: 400,
    data_blank: 400,
    error_code_not_defined: 400,
    email_blank: 400,
    email_conflict: 400,
    email_invalid: 400,
    email_exist: 400,
    invalid_date: 400,
    invalid_phone_number: 400,
    identify_number_blank: 400,
    identify_number_invalid: 400,
    impostor_set_fail: 400,
    judge_name_blank: 400,
    judge_not_exist: 400,
    judge_rating_score_blank: 400,
    lawyer_exist_please_sign_in: 400,
    lawyer_not_found: 400,
    lawyer_not_found_manual_sign_up: 400,
    lawyer_exist: 400,
    lawyer_already_register: 400,
    lawyer_have_password: 400,
    lawyer_have_judgement: 400,
    main_judge_not_exist: 400,
    number_blank: 400,
    open_court_date_blank: 400,
    out_score_intervel: 400,
    observer_already_confirm: 400,
    observer_already_sign_up: 400,
    party_exist: 400,
    party_without_phone_number: 401,
    party_not_found: 400,
    password_invalid: 400,
    password_blank: 400,
    password_confirmation_blank: 400,
    password_less_than_minimum: 400,
    password_not_match_confirmation: 400,
    phone_number_not_verify: 400,
    phone_number_blank: 400,
    phone_number_conflict: 400,
    phone_number_exist: 400,
    phone_number_confirming: 400,
    retry_verify_count_out_range: 400,
    send_email_fail: 400,
    send_sms_too_frequent: 400,
    story_subscriber_failed: 400,
    story_not_exist: 400,
    story_already_pronounced: 400,
    story_already_have_judgement: 400,
    schedule_not_exist: 400,
    schedule_score_update_fail: 400,
    subscribe_fail: 400,
    subscriber_not_sign_up: 401,
    subscriber_without_password: 401,
    subscriber_without_email: 401,
    subscriber_email_not_confirm: 401,
    subscriber_not_confirm: 401,
    quality_score_blank: 400,
    verdict_score_valid_failed: 401,
    verdict_score_not_find: 400,
    verdict_score_exist: 400,
    verdict_judge_name_error: 400,
    without_policy_agreement: 400,
    word_type_blank: 400,
    wrong_phone_number: 400,
    wrong_verify_code: 400,
    wrong_password: 400,
    wrong_court_for_judge: 400,
    year_blank: 400
  }.freeze

  class << self
    def exists?(key)
      status(key).present?
    end

    def status(key)
      STATUS[key.to_sym]
    end

    def desc(key)
      I18n.t("errors.custom_error.#{key}")
    end
  end

end

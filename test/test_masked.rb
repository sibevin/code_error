gem "minitest"
require "minitest/autorun"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require "test_helper"
require "code_error"

class TestMasked < Minitest::Test

  MASK_VALUES = [true, false]

  MASK_ERROR_CODE_1 = :mask_error_code1
  MASK_ERROR_MSG_1 = 'The mask error message for code 1.'
  MASK_ERROR_STATUS_1 = :mask_failed1

  MASK_ERROR_CODE_2 = :mask_error_code2
  MASK_ERROR_MSG_2 = 'The mask error message for code 2.'
  MASK_ERROR_STATUS_2 = :mask_failed2

  MASK_ERROR_CODE_3 = :mask_error_code3
  MASK_ERROR_MSG_3 = 'The mask error message for code 3.'
  MASK_ERROR_STATUS_3 = :mask_failed3

  MASK_ERROR_CODE_UNDEFINED = :mask_undefined_code

  MASK_ERROR_CODES = {
    MASK_ERROR_CODE_1 => {
      :status => MASK_ERROR_STATUS_1,
      :msg => MASK_ERROR_MSG_1,
    },
    MASK_ERROR_CODE_2 => {
      :status => MASK_ERROR_STATUS_2,
      :msg => MASK_ERROR_MSG_2,
      :masked => false
    },
    MASK_ERROR_CODE_3 => {
      :status => MASK_ERROR_STATUS_3,
      :msg => MASK_ERROR_MSG_3,
      :masked => true
    }
  }

  class MaskedError < CodeError::Base
    error_codes (MASK_ERROR_CODES)
  end

  def test_masked_should_mask_the_message_if_the_true_masked_arg_is_given_in_msg_and_data
    e = MaskedError.gen(MASK_ERROR_CODE_1)
    MASK_VALUES.each do |target_mv|
      msg = target_mv ? CodeError::DEFAULT_MASKED_MSG : MASK_ERROR_MSG_1
      assert(e.msg(:masked => target_mv) == msg)
      assert(e.data(:masked => target_mv) == { :code => MASK_ERROR_CODE_1,
                                               :status => MASK_ERROR_STATUS_1,
                                               :msg => msg,
                                               :info => nil })
    end
  end

  def test_masked_should_mask_the_message_if_the_true_masked_arg_is_given_in_msg_and_data_even_the_gen_has_masked_false_option
    MASK_VALUES.each do |mv|
      e = MaskedError.gen(MASK_ERROR_CODE_1, { :masked => mv })
      MASK_VALUES.each do |target_mv|
        msg = target_mv ? CodeError::DEFAULT_MASKED_MSG : MASK_ERROR_MSG_1
        assert(e.msg(:masked => target_mv) == msg)
        assert(e.data(:masked => target_mv) == { :code => MASK_ERROR_CODE_1,
                                                 :status => MASK_ERROR_STATUS_1,
                                                 :msg => msg,
                                                 :info => nil })
      end
    end
  end

  def test_masked_should_mask_the_message_if_the_true_masked_arg_is_given_in_msg_and_data_even_the_code_error_has_masked_false_option
    MASK_ERROR_CODES.each do |code, value|
      error_code = code
      error_msg = value[:msg]
      error_status= value[:status]
      e = MaskedError.gen(error_code)
      MASK_VALUES.each do |target_mv|
        msg = target_mv ? CodeError::DEFAULT_MASKED_MSG : error_msg
        e = MaskedError.gen(error_code)
        assert(e.msg(:masked => target_mv) == msg)
        assert(e.data(:masked => target_mv) == { :code => error_code,
                                                 :status => error_status,
                                                 :msg => msg,
                                                 :info => nil })
      end
    end
  end

  def test_masked_should_mask_the_message_if_the_true_masked_arg_is_given_in_msg_and_data_even_the_class_has_masked_false_option
    MASK_VALUES.each do |mv|
      MaskedError.masked mv
      MASK_VALUES.each do |target_mv|
        msg = target_mv ? CodeError::DEFAULT_MASKED_MSG : MASK_ERROR_MSG_1
        e = MaskedError.gen(MASK_ERROR_CODE_1)
        assert(e.msg(:masked => target_mv) == msg)
        assert(e.data(:masked => target_mv) == { :code => MASK_ERROR_CODE_1,
                                                 :status => MASK_ERROR_STATUS_1,
                                                 :msg => msg,
                                                 :info => nil })
      end
    end
  end

  def test_masked_should_mask_the_message_if_the_gen_has_masked_true_option
    MASK_VALUES.each do |target_mv|
      msg = target_mv ? CodeError::DEFAULT_MASKED_MSG : MASK_ERROR_MSG_1
      e = MaskedError.gen(MASK_ERROR_CODE_1, { :masked => target_mv })
      assert(e.msg == msg)
      assert(e.data == { :code => MASK_ERROR_CODE_1,
                         :status => MASK_ERROR_STATUS_1,
                         :msg => msg,
                         :info => nil })
    end
  end

  def test_masked_should_mask_the_message_if_the_gen_has_masked_true_option_even_the_code_errors_has_masked_false_option
    MASK_ERROR_CODES.each do |code, value|
      error_code = code
      error_msg = value[:msg]
      error_status= value[:status]
      MASK_VALUES.each do |target_mv|
        msg = target_mv ? CodeError::DEFAULT_MASKED_MSG : error_msg
        e = MaskedError.gen(error_code, { :masked => target_mv })
        assert(e.msg == msg)
        assert(e.data == { :code => error_code,
                           :status => error_status,
                           :msg => msg,
                           :info => nil })
      end
    end
  end

  def test_masked_should_mask_the_message_if_the_gen_has_masked_true_option_even_the_class_has_masked_false_option
    MASK_VALUES.each do |mv|
      MaskedError.masked mv
      MASK_VALUES.each do |target_mv|
        msg = target_mv ? CodeError::DEFAULT_MASKED_MSG : MASK_ERROR_MSG_1
        e = MaskedError.gen(MASK_ERROR_CODE_1, { :masked => target_mv })
        assert(e.msg == msg)
        assert(e.data == { :code => MASK_ERROR_CODE_1,
                           :status => MASK_ERROR_STATUS_1,
                           :msg => msg,
                           :info => nil })
      end
    end
  end

  def test_masked_should_mask_the_message_if_the_code_errors_has_masked_true_option
    MASK_ERROR_CODES.each do |code, value|
      error_code = code
      error_msg = value[:msg]
      error_status= value[:status]
      msg = value[:masked] ? CodeError::DEFAULT_MASKED_MSG : error_msg
      e = MaskedError.gen(error_code)
      assert(e.msg == msg)
      assert(e.data == { :code => error_code,
                         :status => error_status,
                         :msg => msg,
                         :info => nil })
    end
  end

  def test_masked_should_mask_the_message_if_the_code_errors_has_masked_true_option_even_the_class_has_masked_false_option
    MASK_VALUES.each do |mv|
      MaskedError.masked mv
      MASK_ERROR_CODES.each do |code, value|
        next if value[:masked].nil?
        error_code = code
        error_msg = value[:msg]
        error_status= value[:status]
        msg = value[:masked] ? CodeError::DEFAULT_MASKED_MSG : error_msg
        e = MaskedError.gen(error_code)
        assert(e.msg == msg)
        assert(e.data == { :code => error_code,
                           :status => error_status,
                           :msg => msg,
                           :info => nil })
      end
    end
  end

  def test_masked_should_mask_the_message_if_the_class_has_masked_true_option
    MASK_VALUES.each do |mv|
      MaskedError.masked mv
      msg = mv ? CodeError::DEFAULT_MASKED_MSG : MASK_ERROR_MSG_1
      e = MaskedError.gen(MASK_ERROR_CODE_1)
      assert(e.msg == msg)
      assert(e.data == { :code => MASK_ERROR_CODE_1,
                         :status => MASK_ERROR_STATUS_1,
                         :msg => msg,
                         :info => nil })
    end
  end
end

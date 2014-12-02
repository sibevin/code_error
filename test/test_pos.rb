gem "minitest"
require "minitest/autorun"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require "test_helper"
require "code_error"

class TestPos < Minitest::Test

  POS_OPTIONS = [:append, :prepend, :none]

  def show_code_msg(pos, msg, code)
    case pos
      when :append then "#{msg} (#{code})"
      when :prepend then "(#{code}) #{msg}"
      else
        msg
    end
  end

  POS_ERROR_CODE_1 = :pos_error_code1
  POS_ERROR_MSG_1 = 'The pos error message for code 1.'
  POS_ERROR_STATUS_1 = :pos_failed1

  POS_ERROR_CODE_2 = :pos_error_code2
  POS_ERROR_MSG_2 = 'The pos error message for code 2.'
  POS_ERROR_STATUS_2 = :pos_failed2

  POS_ERROR_CODE_3 = :pos_error_code3
  POS_ERROR_MSG_3 = 'The pos error message for code 3.'
  POS_ERROR_STATUS_3 = :pos_failed3

  POS_ERROR_CODE_4 = :pos_error_code4
  POS_ERROR_MSG_4 = 'The pos error message for code 4.'
  POS_ERROR_STATUS_4 = :pos_failed4

  POS_ERROR_CODE_UNDEFINED = :pos_undefined_code

  POS_ERROR_CODES = {
    POS_ERROR_CODE_1 => {
      :status => POS_ERROR_STATUS_1,
      :msg => POS_ERROR_MSG_1,
    },
    POS_ERROR_CODE_2 => {
      :status => POS_ERROR_STATUS_2,
      :msg => POS_ERROR_MSG_2,
      :pos => :none
    },
    POS_ERROR_CODE_3 => {
      :status => POS_ERROR_STATUS_3,
      :msg => POS_ERROR_MSG_3,
      :pos => :append
    },
    POS_ERROR_CODE_4 => {
      :status => POS_ERROR_STATUS_4,
      :msg => POS_ERROR_MSG_4,
      :pos => :prepend
    }
  }

  class PosError < CodeError::Base
    error_codes (POS_ERROR_CODES)
  end

  def test_pos_should_put_code_in_msg_if_the_pos_arg_is_given_in_msg_and_data
    POS_OPTIONS.each do |pos|
      e = PosError.gen(POS_ERROR_CODE_1)
      msg = show_code_msg(pos, POS_ERROR_MSG_1, POS_ERROR_CODE_1)
      assert(e.msg(:pos => pos) == msg)
      assert(e.data(:pos => pos) == { :code => POS_ERROR_CODE_1,
                                      :status => POS_ERROR_STATUS_1,
                                      :msg => msg,
                                      :info => nil })
    end
  end

  def test_pos_should_put_code_in_msg_if_the_pos_arg_is_given_in_msg_and_data_even_the_gen_has_other_pos_option
    POS_OPTIONS.each do |pos|
      POS_OPTIONS.each do |pos_target|
        e = PosError.gen(POS_ERROR_CODE_1, { :pos => pos })
        msg = show_code_msg(pos_target, POS_ERROR_MSG_1, POS_ERROR_CODE_1)
        assert(e.msg(:pos => pos_target) == msg)
        assert(e.data(:pos => pos_target) == { :code => POS_ERROR_CODE_1,
                                               :status => POS_ERROR_STATUS_1,
                                               :msg => msg,
                                               :info => nil })
      end
    end
  end

  def test_pos_should_put_code_in_msg_if_the_pos_arg_is_given_in_msg_and_data_even_the_code_error_has_other_pos_option
    POS_ERROR_CODES.each do |code, value|
      error_code = code
      error_msg = value[:msg]
      error_status= value[:status]
      POS_OPTIONS.each do |pos_target|
        e = PosError.gen(error_code)
        msg = show_code_msg(pos_target, error_msg, error_code)
        assert(e.msg(:pos => pos_target) == msg)
        assert(e.data(:pos => pos_target) == { :code => error_code,
                                               :status => error_status,
                                               :msg => msg,
                                               :info => nil })
      end
    end
  end

  def test_pos_should_put_code_in_msg_if_the_pos_arg_is_given_in_msg_and_data_even_the_class_has_other_pos_option
    POS_OPTIONS.each do |pos|
      PosError.pos pos
      POS_OPTIONS.each do |pos_target|
        e = PosError.gen(POS_ERROR_CODE_1)
        msg = show_code_msg(pos_target, POS_ERROR_MSG_1, POS_ERROR_CODE_1)
        assert(e.msg(:pos => pos_target) == msg)
        assert(e.data(:pos => pos_target) == { :code => POS_ERROR_CODE_1,
                                               :status => POS_ERROR_STATUS_1,
                                               :msg => msg,
                                               :info => nil })
      end
    end
  end

  def test_pos_should_put_code_in_msg_if_the_gen_has_pos_option
    POS_OPTIONS.each do |pos|
      e = PosError.gen(POS_ERROR_CODE_1, { :pos => pos })
      msg = show_code_msg(pos, POS_ERROR_MSG_1, POS_ERROR_CODE_1)
      assert(e.msg == msg)
      assert(e.data == { :code => POS_ERROR_CODE_1,
                         :status => POS_ERROR_STATUS_1,
                         :msg => msg,
                         :info => nil })
    end
  end

  def test_pos_should_put_code_in_msg_if_the_gen_has_pos_option_even_the_code_errors_has_other_pos_option
    POS_ERROR_CODES.each do |code, value|
      error_code = code
      error_msg = value[:msg]
      error_status= value[:status]
      POS_OPTIONS.each do |pos_target|
        e = PosError.gen(error_code, { :pos => pos_target })
        msg = show_code_msg(pos_target, error_msg, error_code)
        assert(e.msg == msg)
        assert(e.data == { :code => error_code,
                           :status => error_status,
                           :msg => msg,
                           :info => nil })
      end
    end
  end

  def test_pos_should_put_code_in_msg_if_the_gen_has_pos_option_even_the_class_has_other_pos_option
    POS_OPTIONS.each do |pos|
      PosError.pos pos
      POS_OPTIONS.each do |pos_target|
        e = PosError.gen(POS_ERROR_CODE_1, { :pos => pos_target })
        msg = show_code_msg(pos_target, POS_ERROR_MSG_1, POS_ERROR_CODE_1)
        assert(e.msg == msg)
        assert(e.data == { :code => POS_ERROR_CODE_1,
                           :status => POS_ERROR_STATUS_1,
                           :msg => msg,
                           :info => nil })
      end
    end
  end

  def test_pos_should_put_code_in_msg_if_the_code_errors_has_pos_option
    POS_ERROR_CODES.each do |code, value|
      error_code = code
      error_msg = value[:msg]
      error_status= value[:status]
      e = PosError.gen(error_code)
      msg = show_code_msg(value[:pos], error_msg, error_code)
      assert(e.msg == msg)
      assert(e.data == { :code => error_code,
                         :status => error_status,
                         :msg => msg,
                         :info => nil })
    end
  end

  def test_pos_should_put_code_in_msg_if_the_code_errors_has_pos_option_even_the_class_has_other_pos_option
    POS_OPTIONS.each do |pos|
      PosError.pos pos
      POS_ERROR_CODES.each do |code, value|
        next if value[:pos].nil?
        error_code = code
        error_msg = value[:msg]
        error_status= value[:status]
        e = PosError.gen(error_code)
        msg = show_code_msg(value[:pos], error_msg, error_code)
        assert(e.msg == msg)
        assert(e.data == { :code => error_code,
                           :status => error_status,
                           :msg => msg,
                           :info => nil })
      end
    end
  end

  def test_pos_should_put_code_in_msg_if_the_class_has_pos_option
    POS_OPTIONS.each do |pos|
      PosError.pos pos
      e = PosError.gen(POS_ERROR_CODE_1)
      msg = show_code_msg(pos, POS_ERROR_MSG_1, POS_ERROR_CODE_1)
      assert(e.msg == msg)
      assert(e.data == { :code => POS_ERROR_CODE_1,
                         :status => POS_ERROR_STATUS_1,
                         :msg => msg,
                         :info => nil })
    end
  end

end

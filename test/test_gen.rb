gem "minitest"
require "minitest/autorun"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require "test_helper"
require "code_error"

class TestGen < Minitest::Test
  GEN_ERROR_CODE_1 = :gen_code1
  GEN_ERROR_MSG_1 = 'The error message for gen code 1.'
  GEN_ERROR_STATUS_1 = :gen_failed1

  GEN_ERROR_CODE_2 = :gen_code2
  GEN_ERROR_MSG_2 = 'The error message for gen code 2.'
  GEN_ERROR_STATUS_2 = :gen_failed2

  GEN_ERROR_CODES = {
    GEN_ERROR_CODE_1 => {
      :status => GEN_ERROR_STATUS_1,
      :msg => GEN_ERROR_MSG_1,
    },
    GEN_ERROR_CODE_2 => {
      :status => GEN_ERROR_STATUS_2,
      :msg => GEN_ERROR_MSG_2,
    }
  }

  GEN_ERROR_CODE_UNDEFINED = :undefined_gen_code

  class GenError < CodeError::Base
    error_codes(GEN_ERROR_CODES)
  end

  def test_gen_should_return_the_correspond_data_if_given_code_is_defined
    e = GenError.gen(GEN_ERROR_CODE_1)
    assert(e.code == GEN_ERROR_CODE_1)
    assert(e.status == GEN_ERROR_STATUS_1)
    assert(e.msg == GEN_ERROR_MSG_1)
    assert(e.data == { :code => GEN_ERROR_CODE_1,
                       :status => GEN_ERROR_STATUS_1,
                       :msg => GEN_ERROR_MSG_1,
                       :info => nil })
    assert(e.message == e.data.inspect)
    assert(!e.internal?)
  end

  def test_gen_should_return_an_internal_error_with_given_code_if_given_code_is_undefined
    e = GenError.gen(GEN_ERROR_CODE_UNDEFINED)
    assert(e.code == GEN_ERROR_CODE_UNDEFINED)
    assert(e.status == CodeError::INTERNAL_STATUS)
    assert(e.msg == CodeError::INTERNAL_MSG)
    assert(e.internal?)
  end

  def test_gen_should_return_an_internal_error_with_given_msg_if_given_code_is_a_string
    msg = 'An error message.'
    e = GenError.gen(msg)
    assert(e.code == CodeError::INTERNAL_CODE)
    assert(e.status == CodeError::INTERNAL_STATUS)
    assert(e.msg == msg)
    assert(e.internal?)
  end

  def test_gen_should_return_an_success_error_if_given_code_is_a_success_code
    e = GenError.gen(CodeError::SUCCESS_CODE)
    assert(e.code == CodeError::SUCCESS_CODE)
    assert(e.status == CodeError::SUCCESS_STATUS)
    assert(e.msg == CodeError::SUCCESS_MSG)
    assert(!e.internal?)
  end

  def test_gen_should_contain_the_info_if_an_info_is_given
    info = 'some information'
    e = GenError.gen(GEN_ERROR_CODE_1, { :info => info })
    assert(e.info == info)
  end
end

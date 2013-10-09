require 'test_helper'

describe FlaggerService do
  it '' do
    document = mock
    user = mock
    mailer = mock
    mailer.stubs(deliver: true)
    document.expects(:"flag!").with(user)
    FlagMailer.expects(:flag).with(user, document).returns(mailer)

    FlaggerService.new(user, document).call
  end
end

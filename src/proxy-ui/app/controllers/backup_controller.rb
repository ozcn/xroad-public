#
# The MIT License
# Copyright (c) 2015 Estonian Information System Authority (RIA), Population Register Centre (VRK)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

java_import Java::ee.ria.xroad.common.conf.serverconf.ServerConfDatabaseCtx

class BackupController < BaseBackupController

  skip_around_filter :transaction, :only => [:restore]
  skip_before_filter :check_conf, :read_server_id, :read_owner_name, :only => [:restore]

  upload_callbacks({
    :upload_new => "XROAD_BACKUP.uploadCallback"
  })

  private

  def before_restore
    SignerProxy::getTokens.each do |token|
      if token.id != SignerProxy::SSL_TOKEN_ID
        @hardware_tokens_exist = true
        break
      end
    end
  rescue
  end

  def after_restore
    ServerConfDatabaseCtx.get.closeSessionFactory
  end

  def after_restore_success
    @extra_data = {
      :activate_hardware_tokens => !!@hardware_tokens_exist
    }
  end
end

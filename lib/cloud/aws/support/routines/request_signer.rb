# -*- coding: utf-8 -*-
#--
# Copyright (c) 2016 RightScale, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module RightScale
  module CloudApi
    module AWS
      module Support

        # AWS Support request signer
        class RequestSigner < CloudApi::Routine

          # AWS Support RequestSigner Error
          class Error < CloudApi::Error
          end

          # Authenticates a AWS SUpport request
          #
          # @return [void]
          #
          # @example
          #  # no example
          #
          def process
            action       = @data[:request][:headers]['x-amz-target'].first
            version      = @data[:options][:api_version].gsub('-','')
            content_type = 'application/x-amz-json-1.1'

            # Compile a final request path
            @data[:request][:path] = Utils::join_urn(@data[:connection][:uri].path, @data[:request][:relative_path])

            # Set required headers
            @data[:request][:headers]['x-amz-target'] = ('AWSSupport_%s.%s' % [version, action])
            @data[:request][:headers]['content-type'] = content_type

            # Make sure body is in JSON format
            @data[:request][:body] = {} if @data[:request][:body]._blank?
            if @data[:request][:body].is_a?(Hash)
              @data[:request][:body] = Utils::contentify_body(@data[:request][:body], content_type)
            end

            # Sign a request
            Utils::AWS::sign_v4_signature(
              @data[:credentials][:aws_access_key_id],
              @data[:credentials][:aws_secret_access_key],
              @data[:connection][:uri].host,
              @data[:request],
              :headers
            )
          end

        end

      end
    end
  end
end

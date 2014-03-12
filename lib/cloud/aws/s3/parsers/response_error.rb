#--
# Copyright (c) 2013 RightScale, Inc.
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
    module Parser
      module AWS

        # S3 Parsers namespace
        module S3

          # S3 response error
          class ResponseError

            # Parses HTTP error message from a response body
            #
            # @param [RightScale::CloudApi::HttpResponse] response
            # @param [Hash] options
            # @option options [Object] :xml_parser
            #
            # @return [String] to be displayed/logged.
            #
            # @example
            #    {"Error"=>
            #        {"Message"=>"The specified key does not exist.",
            #        "RequestId"=>"B9BE7751749FA764",
            #        "Code"=>"NoSuchKey",
            #        "HostId"=>
            #          "xtvFjUBrzKb6ndg3XTlGdAkGPm8KByqCzcLdK83fHi++ztDOC83Bv3+uH82DIBHj",
            #        "Key"=>"boot.jpg-"}}
            #
            def self.parse(response, options={})
              body   = response.body.to_s
              result = "#{response.code}"

              return result if body._blank?

              is_xml = response['content-type'].to_s[/xml/] ||
                body[/\A<\?xml /]

              if is_xml
                hash  = Utils::get_xml_parser_class(options[:xml_parser]).parse(body)
                error = hash["Error"]
                result << (error ? ": #{error['Code']}: #{error['Message']} (RequestID: #{error['RequestId']})" : ": #{body}")
              else
                result << ": #{body}"
              end
              result
            end
          end

        end
      end
    end
  end
end

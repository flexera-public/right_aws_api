#--  -*- mode: ruby; encoding: utf-8 -*-
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

require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), 'lib/right_aws_api_version'))

Gem::Specification.new do |spec|
  spec.name             = 'right_aws_api'
  spec.version          = RightScale::CloudApi::AWS::VERSION::STRING
  spec.authors          = ['RightScale, Inc.']
  spec.email            = 'support@rightscale.com'
  spec.summary          = 'The gem provides interface to AWS cloud services.'
  spec.rdoc_options     = ['--main', 'README.md', '--title', '']
  spec.extra_rdoc_files = ['README.md']
  spec.require_path     = 'lib'
  spec.required_ruby_version = '>= 1.8.7'

  spec.add_dependency 'right_cloud_api_base', '>= 0.1.0'

  spec.add_development_dependency 'rake'

  spec.description = <<-EOF
== DESCRIPTION:

right_aws_api gem.

The gem provides interface to AWS cloud services.

EOF

  candidates      = Dir.glob('{lib,spec}/**/*') + ['HISTORY', 'README.md', 'Rakefile', 'right_aws_api.gemspec']
  spec.files      = candidates.sort
  spec.test_files = Dir.glob('spec/**/*')
end

module WPScan
  module Finders
    module Passwords
      # Password attack against the XMLRPC interface
      class XMLRPC < CMSScanner::Finders::Finder
        include CMSScanner::Finders::Finder::BreadthFirstDictionaryAttack

        def login_request(username, password)
          target.method_call('wp.getUsersBlogs', [username, password])
        end

        def valid_credentials?(response)
          response.code == 200 && response.body =~ /blogName/
        end

        def errored_response?(response)
          response.code != 200 && response.body !~ /login_error/i
        end
      end
    end
  end
end

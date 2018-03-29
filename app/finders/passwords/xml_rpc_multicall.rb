module WPScan
  module Finders
    module Passwords
      # Password attack against the XMLRPC interface with multicall method
      class XMLRPCMulticall < CMSScanner::Finders::Finder
        include CMSScanner::Finders::Finder::BreadthFirstDictionaryAttack
      end
    end
  end
end

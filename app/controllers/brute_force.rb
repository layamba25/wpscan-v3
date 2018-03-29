module WPScan
  module Controller
    # Brute Force Controller
    class BruteForce < CMSScanner::Controller::Base
      def cli_options
        [
          OptFilePath.new(
            ['--passwords FILE-PATH', '-P',
             'List of passwords to use during the brute forcing.',
             'If no --username/s option supplied, user enumeration will be run'],
            exists: true
          ),
          OptSmartList.new(['--usernames LIST', '-U', 'List of usernames to use during the brute forcing'])
        ]
      end

      def run
        return unless parsed_options[:passwords]

        if user_interaction?
          output('@info',
                 msg: "Performing password attack on #{finder.titleize} against #{users.size} user/s")
        end

        begin
          found = []

          attacker.attack(users, passwords(parsed_options[:passwords]), show_progression: user_interaction?) do |user|
            found << user

            attacker.progress_bar.log("[SUCCESS] - #{user.username} / #{user.password}")
          end
        ensure
          output('users', users: found)
        end
      end

      # TODO: add an option to let the user choose the attack
      # @return [ CMSScanner::Finders::Finder ] The finder used to perform the attack
      def attacker
        return @attacker if @attacker

        xmlrpc = target.xmlrpc

        @attacker = if xmlrpc&.enabled? && xmlrpc.available_methods.include?('wp.getUsersBlogs')
                      WPScan::Finders::Passwords::XMLRPC.new(xmlrpc)
                    else
                      WPScan::Finders::Passwords::WpLogin.new(target)
                    end
      end

      # @return [ Array<Users> ] The users to brute force
      def users
        return target.users unless parsed_options[:usernames]

        parsed_options[:usernames].reduce([]) do |acc, elem|
          acc << CMSScanner::User.new(elem.chomp)
        end
      end

      # @param [ String ] wordlist_path
      #
      # @return [ Array<String> ]
      def passwords(wordlist_path)
        @passwords ||= File.open(wordlist_path).reduce([]) do |acc, elem|
          acc << elem.chomp
        end
      end
    end
  end
end

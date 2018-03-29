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

        begin
          found = []

          brute_force(users, passwords(parsed_options[:passwords])) do |user|
            found << user

            output('found', user: user) if user_interaction?
          end
        ensure
          output('users', users: found)
        end
      end

      # @return [ Array<Users> ] The users to brute force
      def users
        return target.users unless parsed_options[:usernames]

        parsed_options[:usernames].reduce([]) do |acc, elem|
          acc << CMSScanner::User.new(elem.chomp)
        end
      end

      # the iteration should be on the passwords to be more efficient
      # however, it's not that simple expecially when a combination is found:
      #  - the estimated number of requests (for the progressbar) has to be updated.
      #  - the user found has to be deleted from the loop
      #
      # @param [ Array<User> ] users
      # @param [ Array<String> ] passwords
      #
      # @yield [ User ] when a valid combination is found
      def brute_force(users, passwords)
        hydra = Browser.instance.hydra

        users.each do |user|
          bar = progress_bar(passwords.size, user.username) if user_interaction?

          passwords.each do |password|
            request = target.login_request(user.username, password)

            request.on_complete do |res|
              bar.progress += 1 if user_interaction?

              if res.code == 302
                user.password = password
                hydra.abort

                yield user
                next
              elsif user_interaction? && res.code != 200
                # Errors not displayed when using formats other than cli/cli-no-colour
                output_error(res)
              end
            end

            hydra.queue(request)
          end
          hydra.run
        end
      end

      def progress_bar(size, username)
        ProgressBar.create(
          format: '%t %a <%B> (%c / %C) %P%% %e',
          title: "Brute Forcing #{username} -",
          total: size
        )
      end

      # @param [ String ] wordlist_path
      #
      # @return [ Array<String> ]
      def passwords(wordlist_path)
        @passwords ||= File.open(wordlist_path).reduce([]) do |acc, elem|
          acc << elem.chomp
        end
      end

      # @param [ Typhoeus::Response ] response
      def output_error(response)
        return if response.body =~ /login_error/i

        error = if response.timed_out?
                  'Request timed out.'
                elsif response.code.zero?
                  "No response from remote server. WAF/IPS? (#{response.return_message})"
                elsif response.code.to_s =~ /^50/
                  'Server error, try reducing the number of threads.'
                else
                  "Unknown response received Code: #{response.code}\n Body: #{response.body}"
                end

        output('error', msg: error)
      end
    end
  end
end

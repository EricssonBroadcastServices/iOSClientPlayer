module Fastlane
    module Actions
        module SharedValues
            ##COMMIT_CARTHAGE_DEPENDENCIES_CUSTOM_VALUE = :COMMIT_CARTHAGE_DEPENDENCIES_CUSTOM_VALUE
        end
        
        class UpdateDependencyGraphAction < Action
            def self.run(params)
                #require 'xcodeproj'
                require 'pathname'
                require 'set'
                require 'shellwords'
                
                # find the repo root path
                repo_path = Actions.sh('git rev-parse --show-toplevel').strip
                repo_pathname = Pathname.new(repo_path)
                
                # create our list of files that we expect to have changed, they should all be relative to the project root, which should be equal to the git workdir root
                # 1. Cartfile.resolved
                cartfile = "Cartfile.resolved"
                
                # 2. Carthage/Checkouts/** (ie any change in submodules is ok)
                submodule_directory = "Carthage/Checkouts/"
                
                
                UI.message("Expected Files: #{cartfile} and #{submodule_directory}**")
                
                # get the list of files that have actually changed in our git workdir
                git_dirty_files = Actions.sh('git diff --name-only HEAD').split("\n") + Actions.sh('git ls-files --other --exclude-standard').split("\n")
                
                UI.message("Dirty Files: #{git_dirty_files}")
                
                submodule_changes = git_dirty_files.select { |i| i.start_with?(submodule_directory) }
                UI.message("submodule_changes: #{submodule_changes}")
                valid_changed_files = Array.new(submodule_changes)
                if (git_dirty_files.include? cartfile)
                    valid_changed_files << cartfile
                end
                
                UI.message("Valid Files: #{valid_changed_files}")
                
                # make sure the files changed are related to the Dependency Graph
                changed_files_as_expected = (Set.new(git_dirty_files.map(&:downcase)) == Set.new(valid_changed_files.map(&:downcase)))
                unless changed_files_as_expected
                    unexpected_files_changed = Set.new(git_dirty_files.map(&:downcase)) - Set.new(valid_changed_files.map(&:downcase))
                    error = [
                        "Found unexpected uncommited changes in the working directory.",
                        "The following files not related to the dependency graph was found:",
                        "#{unexpected_files_changed.join("\n")}",
                        "Make sure you have a clean working directory",
                    ].join("\n")
                    UI.user_error!(error)
                    UI.error(error)
                end
    
                UI.message("submodule_changes: #{submodule_changes}")
                
                # make sure we have valid changes before we run git commands
                unless valid_changed_files.empty?
                    UI.message("Valid files MATCH dirty files")
                    
                    # get the absolute paths to the files
                    git_add_paths = valid_changed_files.map do |path|
                        updated = path.gsub("$(SRCROOT)", ".").gsub("${SRCROOT}", ".")
                        File.expand_path(File.join(repo_pathname, updated))
                    end

                    # then create a commit with a message
                    Actions.sh("git add #{git_add_paths.map(&:shellescape).join(' ')}")

                    UI.message("Staged dependencies")
                    begin
                        # TODO: Find version + build number for each submodule and include that in the commit message
                        module_names = submodule_changes.map{|x| x.gsub(submodule_directory,"")}.join(" ")
                        message = "Dependencies updated: #{module_names}"
                        
                        Actions.sh("git commit -m '#{message}'")
                        
                        UI.success("Committed \"#{message}\" 💾.")
                    rescue => ex
                        UI.error(ex)
                        UI.important("Didn't commit any changes.")
                    end
                end

                UI.message("No changes to dependency graph")

            end

            #####################################################
            # @!group Documentation
            #####################################################
            
            def self.description
                "A short description with <= 80 characters of what this action does"
            end
        
            def self.details
                # Optional:
                # this is your chance to provide a more detailed description of this action
                "You can use this action to do cool things..."
            end

            def self.available_options
                [
                    #           # Define all options your action supports.
                    #                                   end),
                    # FastlaneCore::ConfigItem.new(key: :development,
                    #                                        env_name: "FL_COMMIT_CARTHAGE_DEPENDENCIES_DEVELOPMENT",
                    #                                        description: "Create a development certificate instead of a distribution one",
                    #                                        is_string: false, # true: verifies the input is a string, false: every kind of value
                    #                                        default_value: false) # the default value if the user didn't provide one
                ]
            end

            def self.output
#               # Define the shared values you are going to provide
#               # Example
#               [
#                   ['COMMIT_CARTHAGE_DEPENDENCIES_CUSTOM_VALUE', 'A description of what this value contains']
#               ]
            end

            def self.return_value
                # If you method provides a return value, you can describe here what it does
            end

            def self.authors
                # So no one will ever forget your contribution to fastlane :) You are awesome btw!
                ["FredrikSjoberg"]
            end

            def self.is_supported?(platform)
                # you can do things like
                #
                #  true
                #
                #  platform == :ios
                #
                #  [:ios, :mac].include?(platform)
                #

                platform == :ios
            end
        end
    end
end


class StarredcountBuilder < Jenkins::Tasks::Builder

    display_name "Starredcount builder"

    attr_accessor :account, :password

    def initialize(attrs = {})
      @account = attrs['account']
      @password = attrs['password']
    end

    ##
    # Runs before the build begins
    #
    # @param [Jenkins::Model::Build] build the build which will begin
    # @param [Jenkins::Model::Listener] listener the listener for this build.
    def prebuild(build, listener)
      # do any setup that needs to be done before this build runs.
    end

    ##
    # Runs the step over the given build and reports the progress to the listener.
    #
    # @param [Jenkins::Model::Build] build on which to run this step
    # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
    # @param [Jenkins::Model::Listener] listener the listener for this build.
    def perform(build, launcher, listener)
      require 'google/reader'

      Google::Reader::Base.establish_connection(@account, @password)
      unread = Google::Reader::Count.feeds.inject(0){|r,x|r+x.count}
      starred = Google::Reader::Base.get_entries( "http://www.google.com/reader/atom/user/-/state/com.google/starred?n=10000" ).count


      open(build.workspace.realpath + "/googlereadercount.csv", "w+") do |f|
        f.print "time,starred,unread,starred+unread\r\n"
        f.print ",#{starred},#{unread},#{starred+unread}\r\n"
      end

      listener.info("finished output google reader count csv file.")
    end

end

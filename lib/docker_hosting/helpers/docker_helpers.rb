module DockerHosting
  module Helpers
    module DockerHelpers
      def cmd_run(cmd)
        "RUN #{cmd_wrap(cmd)}"
      end

      def cmd_wrap(cmd)
        Array.wrap(cmd).join(" \\ \n    && ")
      end

      def cmd_env_path(path)
        "ENV PATH #{Array.wrap(path).join(':')}:$PATH"
      end

      def cmd_system_package(package)
        cmd_run("yum install -y #{package}")
      end
    end
  end
end

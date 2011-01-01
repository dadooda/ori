module Sample
  module BasicInheritance
    class Grandpa
      def grandpa_public
        true
      end

      protected
      def grandpa_protected
        true
      end

      private
      def grandpa_private
        true
      end

      class << self
        def grandpa_public_singleton
          true
        end

        protected
        def grandpa_protected_singleton
          true
        end

        private
        def grandpa_private_singleton
          true
        end
      end
    end # Grandpa

    class Papa < Grandpa
      def papa_public
        true
      end

      protected
      def papa_protected
        true
      end

      private
      def papa_private
        true
      end

      class << self
        def papa_public_singleton
          true
        end

        protected
        def papa_protected_singleton
          true
        end

        private
        def papa_private_singleton
          true
        end
      end
    end # Papa

    class Son < Papa
      def son_public
        true
      end

      protected
      def son_protected
        true
      end

      private
      def son_private
        true
      end

      class << self
        def son_public_singleton
          true
        end

        protected
        def son_protected_singleton
          true
        end

        private
        def son_private_singleton
          true
        end
      end
    end # Son
  end
end

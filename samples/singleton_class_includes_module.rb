module Sample
  module SingletonClassIncludesModule
    module Mo
      # NOTE: Method names are in context of `Mo`. `Mo` doesn't "know" that they are to become singleton.

      def public_meth
        true
      end

      protected
      def protected_meth
        true
      end

      private
      def private_meth
        true
      end
    end

    class Klass
      class << self
        include Mo
      end
    end

    module OtherMo
      class << self
        include Mo
      end
    end
  end
end
